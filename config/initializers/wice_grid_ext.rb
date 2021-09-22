module Wice
  class WiceGrid
    attr_accessor :no_records_at_all
  end

  class Spreadsheet
    def initialize(name, field_separator, encoding = nil)  #:nodoc:
      @tempfile = Tempfile.new(name)
      @tempfile.set_encoding(encoding) unless encoding.blank?
      @tempfile.write("\xEF\xBB\xBF") # Our addition of byte order mark
      @csv = CSV.new(@tempfile, col_sep: field_separator)
    end
  end
end
