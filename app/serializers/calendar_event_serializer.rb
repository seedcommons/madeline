class CalendarEventSerializer < ActiveModel::Serializer
  attributes :start, :end, :html, :id, :model_id, :editable, :is_finalized, :completed, :model_type,
    :event_type, :has_precedent?, :backgroundColor, :event_classes

  def editable
    return false if (object.event_type == "ghost_step") || object.has_precedent?
    case object.model_type
    when "ProjectStep" then ProjectStepPolicy.new(scope, object.model).update?
    when "Loan" then LoanPolicy.new(scope, object.model).update?
    when "BasicProject" then BasicProjectPolicy.new(scope, object.model).update?
    else false
    end
  end

  # Adjust the end date to display events correctly in the calendar
  # FullCalendar expects an event end date to be 1 day after an event ends
  # Events that occur over a single day need the same start and end date
  def end
    if object.start - object.end <= 1
      object.end
    else
      object.end + 1
    end
  end

  def is_finalized
    object.model_type == "ProjectStep" ? object.model.is_finalized? : nil
  end

  def completed
    object.model_type == "ProjectStep" ? object.model.completed? : nil
  end

  def event_classes
    if object.model_type == "ProjectStep"
      "calendar-event cal-step cal-step-#{object.step_type} #{object.time_status} "\
        "#{object.has_precedent? ? 'has-precedent' : ''} "\
        "#{is_finalized ? 'finalized' : 'draft'}"
    end
  end

  def backgroundColor
    object.background_color
  end
end
