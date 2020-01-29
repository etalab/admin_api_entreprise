require 'csv'

class CsvReader
  attr_reader :file, :options

  def initialize(file, col_sep = ',')
    @file = file
    @options = default_options(col_sep)
  end

  def line_by_line()
    ::CSV.read(file, options).each { |row| yield(row) }
  end

  def default_options(sep)
    {
      col_sep: sep,
      headers: true,
    }
  end
end
