# Helper class to ProjectStep and ProjectStepsController to encapsulate handling of the
# duplication feature modal rendering and execution

require 'chronic'

class ProjectStepDuplication

  # maximum allowed number of records to create when doing a 'duplicate with repeat' operation
  DUPLICATION_RECORD_LIMIT = 60

  attr_reader :basis_date
  attr_reader :step

  def initialize(step)
    @step = step
    @basis_date = step.scheduled_date || Date.today
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
        new_step = duplicate(should_persist: false)
        result = [new_step]
      else
        raise "unexpected repeat duration: #{params[:repeat_duration]}"
    end
    result
  end

  def duplicate_series(frequency, time_unit, month_repeat_on, num_of_occurrences, end_date)
    results = []
    allow_error = true
    last_date = basis_date
    (num_of_occurrences || DUPLICATION_RECORD_LIMIT).times do
      next_date = apply_time_interval(last_date, frequency, time_unit, month_repeat_on)
      puts "next date: #{next_date}"
      break if end_date && next_date > end_date
      results << duplicate(next_date, should_persist: true, allow_error: allow_error)
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
      Chronic.parse("#{month_repeat_on} of next month", now: reference_date)
    end
  end

  def duplicate(date = nil, should_persist: true, allow_error: true)
    begin
      date ||= step.scheduled_date
      new_step = ProjectStep.new(
        project: step.project,
        agent: step.agent,
        step_type_value: step.step_type_value,
        scheduled_date: date,
        original_date: nil,
        completed_date: nil,
        is_finalized: false,
      )
      # This will create transient copies of all of the source translatable attributes.
      step.clone_translations(new_step)
      new_step.save if should_persist
      new_step
      # Note, would likely want to also copy custom fields at the point in time which we expect
      # those to be used on ProjectSteps.
    rescue => e
      Rails.logger.error("create_duplicate error: #{e}")
      raise e if allow_error
      nil  # Partial failures will be stripped from result list.
    end

  end

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

    if (day < 8)
      1
    elsif (8 <= day) && (day < 15)
      2
    elsif (15 <= day) && (day < 22)
      3
    elsif (22 <= day) && (day < 29)
      4
    else
      5
    end
  end

end
