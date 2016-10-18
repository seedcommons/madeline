# Represents a date movement operation on a project step. Not persisted.

module Timeline
  class StepMove
    extend ActiveModel::Naming
    include ActiveModel::Validations
    include ActiveModel::Conversion

    MOVE_TYPES = %i(change_date mark_completed)

    attr_reader :step, :log, :move_type, :days_shifted, :context

    delegate :completed?, to: :step, prefix: true

    def initialize(params = {})
      @step = params[:step]
      @log = params[:log]
      @move_type = params[:move_type] || "change_date"
      @days_shifted = params[:days_shifted].to_i
      @context = params[:context]
    end

    def execute!
      adjust_dates if context == "calendar_drag" # Adjust already happened if context is edit date
      save_new_date_in_log
    end

    def persisted?
      false
    end

    private

    def adjust_dates
      if move_type == "change_date"
        if @step.completed?
          @step.actual_end_date += days_shifted
        else
          @step.scheduled_start_date += days_shifted
        end
      else
        @step.actual_end_date = @step.scheduled_start_date + days_shifted
      end
      @step.save(validate: false)
    end

    def save_new_date_in_log
      @log.date_changed_to = @step.scheduled_start_date
    end
  end
end
