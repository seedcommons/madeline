# Represents a date movement operation on a project step. Not persisted.
class ProjectStepMove
  extend ActiveModel::Naming
  include ActiveModel::Validations
  include ActiveModel::Conversion

  MOVE_TYPES = %i(change_date mark_completed)

  attr_reader :step, :move_type, :shift_subsequent, :days_shifted, :context

  delegate :completed?, to: :step, prefix: true

  alias_method :shift_subsequent?, :shift_subsequent

  def initialize(params = {})
    @step = params[:step]
    @move_type = params[:move_type] || "change_date"
    @shift_subsequent = params[:shift_subsequent] == "1"
    @days_shifted = params[:days_shifted].to_i
    @context = params[:context]
  end

  def execute!
    adjust_dates if context == "calendar_drag" # Adjust already happened if context is edit date
    do_shift if shift_subsequent?
  end

  def persisted?
    false
  end

  private

  def adjust_dates
    if move_type == "change_date"
      if @step.completed?
        @step.completed_date += days_shifted
      else
        @step.scheduled_date += days_shifted
      end
    else
      @step.completed_date = @step.scheduled_date + days_shifted
    end
    @step.save(validate: false)
  end

  def do_shift
    date_before_move = @step.scheduled_date - days_shifted
    subsequent = @step.project.project_steps.
      where("scheduled_date >= :date AND completed_date IS NULL AND id != :id",
        date: date_before_move, id: @step.id)
    subsequent.each { |s| s.update_attribute(:scheduled_date, s.scheduled_date + days_shifted) }
  end
end
