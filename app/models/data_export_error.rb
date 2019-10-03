class DataExportError < StandardError
  attr_accessor :child_errors

  def initialize(message: nil, child_errors: [])
    @child_errors = child_errors
    super(message)
  end
end
