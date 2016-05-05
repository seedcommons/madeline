class Admin::CalendarController < Admin::AdminController
  def index
    @division = current_division
    authorize @division

    # This version of the events url is more RESTful and would support a stable calendar view
    # context and support multiple calendar views being navigated from in different tabs.
    # @calendar_events_url = "/admin/calendar_events/division/#{@division.id}"

    # For now, simply honor the currently selected division even if it changes after calendar view
    # first loaded.
    @calendar_events_url = "/admin/calendar_events"
  end
end
