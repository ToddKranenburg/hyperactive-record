require_relative 'db_connection'
require_relative 'sql_base'

module Searchable
  def where(params)
    where_line = params.map { |attr_name, attr_value| "#{attr_name} = '#{attr_value}'"}
      .join(' AND ')

    Relation.new(where_line, self.to_s)
  end

  # def where(params)
  #   where_line = params.map { |attr_name, attr_value| "#{attr_name} = '#{attr_value}'"}
  #     .join(' AND ')
  #   results = DBConnection.execute(<<-SQL)
  #     SELECT
  #       #{table_name}.*
  #     FROM
  #       #{table_name}
  #     WHERE
  #       #{where_line}
  #   SQL
  #
  #   self.parse_all(results)
  # end
end

class Relation
  def where_line
    @where_line
  end
  def initialize(where_line, super_class)
    @where_line = where_line
    @table_name = super_class.constantize.table_name
    @super_class = super_class
  end

  def where(params)
    additional_where_line = params.map { |attr_name, attr_value| "#{attr_name} = '#{attr_value}'"}
    .join(' AND ')

    @where_line = [@where_line, additional_where_line].join(' AND ')
    self
  end

  def method_missing(name, *args)
    execute_relation.send(name, *args)
  end

  def execute_relation
    results = DBConnection.execute(<<-SQL)
      SELECT
        #{@table_name}.*
      FROM
        #{@table_name}
      WHERE
        #{@where_line}
    SQL

    @super_class.constantize.parse_all(results)
  end
end

class SQLBase
  extend Searchable
end
