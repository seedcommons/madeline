# Represents a date movement operation on a project step. Not persisted.
class ProjectStepMove
  extend ActiveModel::Naming
  include ActiveModel::Validations
  include ActiveModel::Conversion

  MOVE_TYPES = %i(change_sched_date mark_completed)

  attr_reader :step, :move_type, :shift_subsequent

  delegate :completed?, to: :step, prefix: true

  def initialize(step: nil, move_type: nil, shift_subsequent: nil)
    @step = step
    @move_type = move_type || "change_sched_date"
    @shift_subsequent = shift_subsequent
  end

  def persisted?
    false
  end
end
