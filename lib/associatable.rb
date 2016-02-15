require_relative "searchable"
require_relative "attr"
require 'active_support/inflector'

class AssocOptions < AttrObject
  my_attr_accessor :foreign_key, :class_name, :primary_key

  def model_class
    class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    defaults = {
      class_name: name.to_s.singularize.camelize,
      foreign_key: (name.to_s + '_id').to_sym,
      primary_key: :id
    }
    options = defaults.merge(options)

    options.each_pair { |attr_name, attr_value| send("#{attr_name}=", attr_value) }
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    defaults = {
      class_name: name.to_s.singularize.camelize,
      foreign_key: (self_class_name.to_s.singularize.underscore + '_id').to_sym,
      primary_key: :id
    }
    options = defaults.merge(options)

    options.each_pair { |attr_name, attr_value| send("#{attr_name}=", attr_value) }
  end
end

module Associatable
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    assoc_options[name] = options

    define_method(name) do
      model_class = options.model_class
      foreign_key_value = send(options.foreign_key)

      model_class.where(id: foreign_key_value).first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.to_s, options)
    assoc_options[name] = options

    define_method(name) do
      model_class = options.model_class
      model_class.where(options.foreign_key => self.id)
    end
  end

  def assoc_options
    @assoc_options ||= {}
  end


  def has_one_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]

      through_table_name = through_options.table_name
      through_fk = through_options.foreign_key
      through_pk = through_options.primary_key

      source_table_name = source_options.table_name
      source_fk = source_options.foreign_key
      source_pk = source_options.primary_key

      results = DBConnection.execute(<<-SQL)
        SELECT
          #{source_table_name}.*
        FROM
          #{through_table_name}
        JOIN
          #{source_table_name}
        ON
          #{through_table_name}.#{source_fk} = #{source_table_name}.#{source_pk}
        WHERE
          #{send(through_fk)} = #{through_table_name}.#{through_pk}
      SQL

      source_options.model_class.parse_all(results).first
    end
  end

  def has_many_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]

      through_table_name = through_options.table_name
      through_fk = through_options.foreign_key
      through_pk = through_options.primary_key

      source_table_name = source_options.table_name
      source_fk = source_options.foreign_key
      source_pk = source_options.primary_key

      results = DBConnection.execute(<<-SQL)
        SELECT
          #{source_table_name}.*
        FROM
          #{through_table_name}
        JOIN
          #{source_table_name}
        ON
          #{through_table_name}.#{source_pk} = #{source_table_name}.#{source_fk}
        WHERE
          #{send(through_pk)} = #{through_table_name}.#{through_fk}
      SQL

      source_options.model_class.parse_all(results)
    end
  end
end

class SQLBase
  extend Associatable
end
