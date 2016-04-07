class Admin::CalendarController < Admin::AdminController
  def index
    @division = current_division
    @loans = current_division.loans
    @events = []

    @loans.each do |loan|
      self.prepare_event(loan.calendar_start_event)
      self.prepare_event(loan.calendar_end_event)

      loan.project_steps.each do |step|
        self.prepare_event(step.calendar_scheduled_event)
      end
    end
  end

  def prepare_event(cal_event)
    @events.push(cal_event)
  end
end
