class CalendarEvent
  include ActiveModel::Serialization

  attr_accessor :start
  attr_accessor :end
  attr_accessor :title
  attr_accessor :html  # transient value populated by controller and serialized as "title"

  attr_accessor :event_type
  attr_accessor :model
  attr_accessor :model_type

  attr_accessor :background_color
  attr_accessor :event_classes

  attr_accessor :step_type
  attr_accessor :completion_status
  attr_accessor :time_status
  attr_accessor :num_of_logs

  attr_accessor :has_precedent
  alias_method :has_precedent?, :has_precedent

  def self.build_for(item)
    puts "item: #{item.inspect}"
    case item
    when BasicProject
      [new_project_start(item), new_project_end(item)]
    when Loan
      [new_project_start(item), new_project_end(item)]
    when ProjectStep
      [new_project_step(item)]
    else
      raise "CalendarEvent.build_for - unexpected model class: #{item.class}"
    end.compact
  end

  def self.new_project_step(step)
    step.scheduled_start_date ? new.initialize_project_step(step) : nil
  end

  def self.new_ghost_step(step)
    step.old_start_date ? new.initialize_ghost_step(step) : nil
  end

  def self.new_project_start(project)
    project.signing_date ? new.initialize_project_start(project) : nil
  end

  def self.new_project_end(project)
    project.end_date ? new.initialize_project_end(project) : nil
  end

  def self.filtered_events(date_range: nil, project_filter: nil, project_scope: Project, step_scope: ProjectStep)
    events = project_events_by_date_project_scope(date_range, project_scope.where(project_filter))
    events += step_events_by_date_project_filter(date_range: date_range, project_filter: project_filter,
      scope: step_scope)

    # Filter out sibling events outside of our range
    events.select!{ |event| date_range === event.start }
    events
  end

  def self.project_events_by_date_project_scope(range, scope = Project)
    project_date_filter(range, scope).map(&:calendar_events).flatten
  end

  def self.step_events_by_date_project_filter(date_range: nil, project_filter: nil, scope: ProjectStep)
    project_step_date_filter(date_range, scope).
      # Would be nice to be able to use a join here, but this performs okay with the full migrated
      # data, and I'm not sure if it's possible without entirely hand crafted SQL
      where(project_id: Project.where(project_filter).pluck(:id)).
      map(&:calendar_events).flatten
  end

  def self.test(project_filter)
    ProjectStep.joins(:projects).where(projects: project_filter)
  end

  def self.project_date_filter(range, scope = Project)
    # Seems like a nice 'OR' syntax won't be available until Rails 5.
    # Project.where(signing_date: date_range).or(end_date: date_range)
    scope.where("signing_date BETWEEN :first AND :last OR end_date between :first AND :last",
                {first: range.first, last: range.last})
  end

  def self.project_step_date_filter(range, scope = ProjectStep)
    scope.where("actual_end_date BETWEEN :first AND :last OR scheduled_start_date BETWEEN :first AND :last "\
      "OR old_start_date BETWEEN :first and :last", {first: range.first, last: range.last})
  end

  def initialize_project_step(step)
    @start = step.calendar_start_date
    @end = step.calendar_end_date
    @title = step.name.to_s
    @background_color = step.color

    @event_type = "project_step"
    @num_of_logs = step.logs_count
    @model_type = "ProjectStep"
    @model = step

    @step_type = step.step_type_value
    @completion_status = step.completion_status
    @time_status = step.days_late && step.days_late > 0 ? "late" : "on_time"
    @has_precedent = step.schedule_parent_id.present?
    self
  end

  def initialize_ghost_step(step)
    @start = step.old_start_date
    @end = step.display_end_date
    @title = step.name.to_s
    @event_type = "ghost_step"
    @num_of_logs = step.logs_count
    @model_type = "ProjectStep"
    @model = step
    @step_type = step.step_type_value
    self
  end

  def initialize_project_start(project)
    @start = project.signing_date
    @end = project.signing_date
    @title = I18n.t("loan.start", name: project.display_name)
    @event_type = "project_start"
    @model_type = project.type
    @model = project
    self
  end

  def initialize_project_end(project)
    @start = project.end_date
    @end = project.end_date
    @title = I18n.t("loan.end", name: project.display_name)
    @event_type = "project_end"
    @model_type = project.type
    @model = project
    self
  end

  def id
    "#{event_type}-#{model_id}"
  end

  def model_id
    model.id
  end
end
