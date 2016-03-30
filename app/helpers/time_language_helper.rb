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

  # The below methods are stubbed and can be removed as needed

  def time_status(step)
    set_dates(step)
    return ""  unless @scheduled

    time_diff = @actual - @scheduled

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
    status = time_status(step)

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

  def status_statement(step)
    set_dates(step)
    return ''  unless @scheduled
    date_diff = time_diff_in_natural_language(@scheduled, @actual)
    days_status = time_status(step)
    # todo: discuss if we really want to display an 'x days early' status if the does not yet have an assigned completed_date
    days_statement = t("project_step.status.time_#{days_status}", time: date_diff)

    return days_statement
  end
end
