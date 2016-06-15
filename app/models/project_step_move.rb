# Represents a date movement operation on a project step. Not persisted.
class ProjectStepMove
  extend ActiveModel::Naming
  include ActiveModel::Validations
  include ActiveModel::Conversion

  MOVE_TYPES = %i(change_sched_date mark_completed)

  attr_reader :step, :move_type, :shift_subsequent, :days_shifted, :context

  delegate :completed?, to: :step, prefix: true

  def initialize(params = {})
    @step = params[:step]
    @move_type = params[:move_type] || "change_sched_date"
    @shift_subsequent = params[:shift_subsequent] == "1"
    @days_shifted = params[:days_shifted]
    @context = params[:context]
  end

  def execute!
    # if move_type == "change_sched_date"
    #   @step.scheduled_date =

  end

  def persisted?
    false
  end
end
