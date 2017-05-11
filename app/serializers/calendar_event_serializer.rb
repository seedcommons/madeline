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

  def is_finalized
    object.model_type == "ProjectStep" ? object.model.is_finalized? : nil
  end

  def completed
    object.model_type == "ProjectStep" ? object.model.completed? : nil
  end

  def event_classes
    if object.model_type == "ProjectStep"
      "calendar-event cal-step cal-step-#{object.step_type} #{object.time_status} #{object.has_precedent? ? 'has-precedent': ''} "
    end
  end
end
