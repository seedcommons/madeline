class CalendarEvent
  include ActiveModel::Serialization

  attr_accessor :start
  attr_accessor :title
  attr_accessor :html  # transient value populated by controller and serialized as 'title'

  attr_accessor :event_type
  attr_accessor :model
  attr_accessor :model_type

  attr_accessor :background_color
  attr_accessor :step_type
  attr_accessor :completion_status
  attr_accessor :time_status
  attr_accessor :num_of_logs

  def self.build_for(model)
    puts "model: #{model.inspect}"
    case model
    when Loan
      [new_loan_start(model), new_loan_end(model)]
    when ProjectStep
      [new_project_step(model), new_ghost_step(model)]
    else
      raise "CalendarEvent.build_for - unexpected model class: #{model.class}"
    end.compact
  end

  def self.new_project_step(step)
    step.calendar_date ? new.initialize_project_step(step) : nil
  end

  def self.new_ghost_step(step)
    step.original_date ? new.initialize_ghost_step(step) : nil
  end

  def self.new_loan_start(loan)
    loan.signing_date ? new.initialize_loan_start(loan) : nil
  end

  def self.new_loan_end(loan)
    loan.target_end_date ? new.initialize_loan_end(loan) : nil
  end

  def self.filtered_events(date_range: nil, loan_filter: nil, loan_scope: Loan, step_scope: ProjectStep)
    events = loan_events_by_date_loan_scope(date_range, loan_scope.where(loan_filter))
    events += step_events_by_date_loan_filter(date_range: date_range, loan_filter: loan_filter,
      scope: step_scope)

    # Filter out sibling events outside of our range
    events.select!{ |event| date_range === event.start }
    events
  end

  def self.loan_events_by_date_loan_scope(range, scope = Loan)
    loan_date_filter(range, scope).map(&:calendar_events).flatten
  end

  def self.step_events_by_date_loan_filter(date_range: nil, loan_filter: nil, scope: ProjectStep)
    project_step_date_filter(date_range, scope).
      # Would be nice to be able to use a join here, but this performs okay with the full migrated
      # data, and I'm not sure if it's possible without entirely hand crafted SQL
      where(project_type: 'Loan', project_id: Loan.where(loan_filter).pluck(:id)).
      map(&:calendar_events).flatten
  end

  def self.test(loan_filter)
    ProjectStep.joins(:loans).where(loans: loan_filter)
  end

  def self.loan_date_filter(range, scope = Loan)
    # Seems like a nice 'OR' syntax won't be available until Rails 5.
    # Loan.where(signing_date: date_range).or(target_end_date: date_range)
    scope.where("signing_date BETWEEN :first AND :last OR target_end_date between :first AND :last",
                {first: range.first, last: range.last})
  end

  def self.project_step_date_filter(range, scope = ProjectStep)
    scope.where("completed_date BETWEEN :first AND :last OR scheduled_start_date BETWEEN :first AND :last "\
      "OR original_date BETWEEN :first and :last", {first: range.first, last: range.last})
  end

  def initialize_project_step(step)
    @start = step.calendar_date
    @title = step.name.to_s
    @background_color = step.color

    @event_type = "project_step"
    @num_of_logs = step.logs_count
    @model_type = 'ProjectStep'
    @model = step

    @step_type = step.step_type_value
    # could update to use step.completed_or_not
    @completion_status = step.completed? ? "complete" : "incomplete"
    @time_status = step.days_late && step.days_late > 0 ? "late" : "on_time"
    self
  end

  def initialize_ghost_step(step)
    @start = step.original_date
    @title = step.name.to_s
    @event_type = "ghost_step"
    @num_of_logs = step.logs_count
    @model_type = 'ProjectStep'
    @model = step
    @step_type = step.step_type_value
    self
  end

  def initialize_loan_start(loan)
    @start = loan.signing_date
    @title = "Start " + loan.name
    @event_type = "loan_start"
    @model_type = 'Loan'
    @model = loan
    self
  end

  def initialize_loan_end(loan)
    @start = loan.target_end_date
    @title = "End " + loan.name
    @event_type = "loan_end"
    @model_type = 'Loan'
    @model = loan
    self
  end

  def id
    "#{event_type}-#{model_id}"
  end

  def model_id
    model.id
  end
end
