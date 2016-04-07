class Admin::CalendarController < Admin::AdminController
  def index
    @division = current_division
    @loans = current_division.loans
    @events = []

    @loans.each do |loan|
      @events.push(loan.calendar_start_event)
      @events.push(loan.calendar_end_event)
    end
  end
end
