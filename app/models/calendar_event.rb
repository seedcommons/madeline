class CalendarEvent
  include ActiveModel::Serialization

  attr_accessor :start_date
  attr_accessor :title
  attr_accessor :html  # transient value populated by controller and serialized as 'title'

  attr_accessor :start
  attr_accessor :title
  attr_accessor :backgroundColor

  attr_accessor :event_type
  attr_accessor :num_of_logs

  # JE Todo: Confirm if potentially useful and worth including
  attr_accessor :model_type  #Loan/ProjectStep
  attr_accessor :model_id

  attr_accessor :step_type
  attr_accessor :completion_status
  attr_accessor :time_status

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

  def initialize_project_step(step)
    @start = step.calendar_date
    @title = step.name.to_s
    @backgroundColor = step.color

    @event_type = "project_step"
    @num_of_logs = step.logs_count
    @model_type = 'ProjectStep'
    @model_id = step.id

    # @step_type = step.milestone? ? "milestone" : "checkin"
    @step_type = step.step_type_value
    # JE Todo - update to use step.completed_or_not
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
    @model_id = step.id
    self
  end

  def initialize_loan_start(loan)
    @start = loan.signing_date
    @title = "Start " + loan.name
    @event_type = "loan_start"
    @model_type = 'Loan'
    @model_id = loan.id
    self
  end

  def initialize_loan_end(loan)
    @start = loan.target_end_date
    @title = "End " + loan.name
    @event_type = "loan_end"
    @model_type = 'Loan'
    @model_id = loan.id
    self
  end

  def self.filtered_events(date_range, loan_filter, loan_scope = Loan, step_scope = ProjectStep)
    events = loan_events_by_date_loan_scope(date_range, loan_scope.where(loan_filter))
    # JE Todo: apply project_step_scope scope
    events += step_events_by_date_loan_filter(date_range, loan_filter, step_scope)

    puts "before select event count: #{events.count}" #JE Todo: remove
    # Filter out sibling events outside of our range
    events.select!{ |event| date_range === event.start }
    puts "after select event count: #{events.count}, first: #{events.first.inspect}" #JE Todo: remove
    events
  end

  def self.loan_date_filter(range, scope = Loan)
    # Seems like a nice 'OR' syntax won't be available until Rails 5.
    # Loan.where(signing_date: date_range).or(target_end_date: date_range)
    scope.where("signing_date between :first and :last OR target_end_date between :first and :last",
      {first: range.first, last: range.last})
  end

  def self.loan_events_by_date_loan_scope(range, scope = Loan)
    # Seems like a nice 'OR' syntax won't be available until Rails 5.
    # Loan.where(signing_date: date_range).or(target_end_date: date_range)
    scope.where("signing_date between :first and :last OR target_end_date between :first and :last",
      {first: range.first, last: range.last}).
      map(&:calendar_events).flatten
  end

  def self.project_step_date_filter(range, scope = ProjectStep)
    scope.where("completed_date between :first and :last OR scheduled_date between :first and :last "\
      "OR original_date between :first and :last", {first: range.first, last: range.last})
  end

  def self.step_events_by_date_loan_filter(date_range, loan_filter, scope = ProjectStep)
    project_step_date_filter(date_range, scope).
      where(project_type: 'Loan', project_id: Loan.where(loan_filter).pluck(:id)).  #JE Todo: should be able to use a join here
      map(&:calendar_events).flatten
  end

end
