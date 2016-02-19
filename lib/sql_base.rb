require_relative 'db_connection'
require 'active_support/inflector'

class SQLBase
  def self.table_name
    @table_name ||= self.to_s.tableize
  end

  def self.table_name=(val)
    @table_name = val
  end

  def self.columns
    @columns ||= DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL
      .first.map { |column| column.to_sym }
  end

  def self.finalize!
    columns.each do |column|
      define_method("#{column}=") do |val|
        self.attributes[column] = val
      end

      define_method(column) do
        self.attributes[column]
      end
    end
  end

  def self.all
    results = DBConnection.execute(<<-SQL)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
    SQL

    parse_all(results)
  end

  def self.parse_all(results)
    parsed_results = [];

    results.each do |result|
      parsed_results << self.new(result)
    end

    parsed_results
  end

  def self.find(id)
    results = DBConnection.execute(<<-SQL)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
      WHERE
        #{table_name}.id = #{id}
    SQL

    results.empty? ? nil : self.new(results.first)
  end

  def initialize(params = {})
    params.each do |attr_name, val|
      attr_name_symbol = attr_name.to_sym
      raise "unknown attribute '#{attr_name}'" unless self.class.columns.include?(attr_name_symbol)
      send("#{attr_name}=", val)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map do |attr_name|
      send(attr_name)
    end
  end

  def insert
    col_names = self.class.columns
    question_marks = (["?"] * col_names.length).join(', ')
    col_names = col_names.join(', ')

    DBConnection.execute(<<-SQL, attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def update
    set_line = self.class.columns.map { |attr_name| "#{attr_name} = ?"}.join(', ')
    DBConnection.execute(<<-SQL, attribute_values)
      UPDATE
        #{self.class.table_name}
      SET
        #{set_line}
      WHERE
        #{self.class.table_name}.id = #{id}
    SQL
  end

  def save
    id ? update : insert
  end
end
