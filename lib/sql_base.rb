require_relative 'db_connection'
require_relative 'attr'

class SQLBase < AttrObject
  my_attr_writer :table_name

  def self.table_name
    @table_name ||= self.to_s.tableize
  end

  def self.columns
    @columns || = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL
      .first.map { |column| column.to_sym }
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
  end
end
