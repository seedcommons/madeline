class Admin::CalendarController < Admin::AdminController
  def index
    @division = current_division
    authorize @division

    #JE Todo: Confirm if we want to support an 'all' view, or just the currently selected division.
    @calendar_events_url = "/admin/calendar_events/division/#{@division.id}"
  end

end
