class Admin::CalendarController < Admin::AdminController
  def index
    @division = current_division
    @loans = current_division.loans

    authorize @division

    #JE Todo: Confirm if we want to support an 'all' view, or just the currently selected division.
    @calendar_events_url = "/admin/calendar_events/division/#{@division.id}"

    # @loans.each do |loan|
    #   @calEvents.concat( loan_events(loan) )
    # end

  end

end
