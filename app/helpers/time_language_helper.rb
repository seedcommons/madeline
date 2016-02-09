module TimeLanguageHelper
  def time_diff_in_natural_language(from_time, to_time)
    from_time = from_time.to_time if from_time.respond_to?(:to_time)
    to_time = to_time.to_time if to_time.respond_to?(:to_time)
    distance_in_seconds = ((to_time - from_time).abs).round
    components = []

    %w(year month week day).each do |interval|
      # For each interval type, if the amount of time remaining is greater than
      # one unit, calculate how many units fit into the remaining time.
      if distance_in_seconds >= 1.send(interval)
        delta = (distance_in_seconds / 1.send(interval)).floor
        distance_in_seconds -= delta.send(interval)
        components << pluralize(delta, interval)
      end
    end

    components.join(", ")
  end

  def time_status(from_time, to_time)
    time_diff = to_time - from_time

    if time_diff < 0
      status = "early"
    elsif time_diff > 0
      status = "late"
    else
      status = "on_time"
    end

    return status
  end

  def status_class(step)
    set_dates(step)
    status = time_status(@scheduled, @actual)

    if status == "on_time"
      return "on-time"
    else
      return status
    end
  end

  def set_dates(step)
    @scheduled = step.scheduled_date

    unless step.completed_date
      @actual = Date.today
    else
      @actual = step.completed_date
    end
  end

  def status_statement(from_time, to_time)
    date_diff = time_diff_in_natural_language(from_time, to_time)
    days_status = time_status(from_time, to_time)
    days_statement = t("project_step.status.#{days_status}", time: date_diff)

    return days_statement
  end
end
