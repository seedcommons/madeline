class Admin::CalendarController < Admin::AdminController
  def index
    @division = current_division
    @loans = current_division.loans

    authorize @division

    #JE Todo: rename with snakecase
    @calEvents = []

    @loans.each do |loan|
      @calEvents.concat( loan_events(loan) )
    end

  end

end
