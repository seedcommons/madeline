# Represents a date movement operation on a project step. Not persisted.
class ProjectStepMove
  extend ActiveModel::Naming
  include ActiveModel::Validations
  include ActiveModel::Conversion

  attr_reader :move_type, :shift_subsequent

  def initialize(move_type: nil, shift_subsequent: nil)
    @move_type = move_type
    @shift_subsequent = shift_subsequent
  end

  def persisted?
    false
  end
end
