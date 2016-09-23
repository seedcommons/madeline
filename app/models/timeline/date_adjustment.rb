module Timeline
  # Timeline::StepMove could probably use this as well.
  # There is a bunch of duplications between these classes
  class DateAdjustment < BatchOp
    def initialize(user, step_ids, time_direction:, num_of_days:)
      super(user, step_ids)
      @time_direction = time_direction
      @num_of_days = num_of_days
    end

    protected

    def authorization_key
      :adjust_dates?
    end

    def batch_operation(user, step)
      adjust_scheduled_date(step, days_adjustment)
    end

    def days_adjustment
      sign = case @time_direction
      when 'forward' then 1
      when 'backward' then -1
      else raise "adjust_dates - unexpected or missing time_direction: #{time_direction}"
      end
      sign * @num_of_days
    end

    def adjust_scheduled_date(step, days_adjustment)
      if step.scheduled_start_date && days_adjustment != 0
        new_date = step.scheduled_start_date + days_adjustment.days
        # note, old_start_date will be assigned if needed by the before_save logic
        step.update!(scheduled_start_date: new_date)
      else
        false
      end
    end
  end
end
