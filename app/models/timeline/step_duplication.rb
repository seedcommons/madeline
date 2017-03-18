# Helper class to ProjectStep and ProjectStepsController to encapsulate handling of the
# duplication feature modal rendering and execution
require 'chronic'

module Timeline
  class StepDuplication
    # maximum allowed number of records to create when doing a 'duplicate with repeat' operation
    DUPLICATION_RECORD_LIMIT = 60

    attr_reader :basis_date
    attr_reader :step

    def initialize(step)
      @step = step
      @basis_date = step.scheduled_start_date || Date.today
    end

    def perform(params)
      case params[:repeat_duration]
        when 'custom_repeat'
          frequency = params[:time_unit_frequency].to_i
          raise "invalid time unit frequency: #{frequency}" if frequency <= 0
          time_unit = params[:time_unit].to_sym  # days, weeks, months

          # Expects back a Chronic gem compatible string.  i.e. '26th day' or '4th Tuesday'
          month_repeat_on = params[:month_repeat_on] if time_unit == :months

          end_occurrence_type = params[:end_occurrence_type].to_sym
          if end_occurrence_type == :count
            num_of_occurrences = params[:num_of_occurrences].to_i
            end_date = nil
          else
            end_date = params[:end_date]
            num_of_occurrences = nil
          end
          result = duplicate_series(frequency, time_unit, month_repeat_on, num_of_occurrences, end_date).compact
        when 'once'
          result = [duplicate]
        else
          raise "unexpected repeat duration: #{params[:repeat_duration]}"
      end
      result
    end

    # These seem to be helpers for the date dialog. They could probably
    # be extracted into a helper method or class
    def basis_day
      basis_date.day
    end

    def basis_weekday
      Date::DAYNAMES[basis_date.wday]
    end

    def basis_weekday_key
      basis_week.to_s + "_" + basis_weekday.downcase
    end

    # Returns which week within a given month the scheduled date (or current date if absent) occurs.
    def basis_week
      day = basis_day.to_i
      (day - 1).div(7) + 1
    end

    private

    def duplicate_series(frequency, time_unit, month_repeat_on, num_of_occurrences, end_date)
      results = []
      allow_error = true
      last_date = basis_date
      (num_of_occurrences || DUPLICATION_RECORD_LIMIT).times do
        next_date = apply_time_interval(last_date, frequency, time_unit, month_repeat_on)
        break if end_date && next_date > end_date
        results << duplicate(next_date, allow_error: allow_error)
        last_date = next_date
        allow_error = false  # only throw exception if the first record fails
      end
      results
    end

    def apply_time_interval(date, frequency, time_unit, month_repeat_on)
      interval = frequency.send(time_unit)
      if time_unit == :days || time_unit == :weeks
        date + interval
      else
        # Note, Chronic doesn't seem to support 'this month' in this context, so need to subtract
        # a month and use 'next month'.
        reference_date = date.beginning_of_month + interval - 1.month
        first_try = Chronic.parse("#{month_repeat_on} of next month", now: reference_date)

        # Sometimes 5th weekday of month doesn't exist
        if first_try.nil? && month_repeat_on =~ /\A5th/
          Chronic.parse("#{month_repeat_on.sub('5th', '4th')} of next month", now: reference_date)
        else
          first_try
        end
      end
    end

    def duplicate(date = nil, allow_error: true)
      begin
        date ||= step.scheduled_start_date
        new_step = ProjectStep.new(
          project: step.project,
          parent: step.parent,
          agent: step.agent,
          step_type_value: step.step_type_value,
          scheduled_start_date: date,
          scheduled_duration_days: step.scheduled_duration_days,
          old_start_date: nil,
          actual_end_date: nil,
          is_finalized: false,
        )
        step.clone_translations(new_step)
        new_step.save
        new_step
      rescue => e
        Rails.logger.error("create_duplicate error: #{e}")
        raise e if allow_error
        nil # Partial failures will be stripped from result list.
      end
    end
  end
end
