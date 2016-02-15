require_relative 'db_connection'
require_relative 'sql_base'

module Searchable
  def where(params)
    where_line = params.map { |attr_name, attr_value| "#{attr_name} = '#{attr_value}'"}
      .join(' AND ')
    results = DBConnection.execute(<<-SQL)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
      WHERE
        #{where_line}
    SQL

    self.parse_all(results)
  end
end

class SQLBase
  extend Searchable
end
