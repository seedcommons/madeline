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

end
