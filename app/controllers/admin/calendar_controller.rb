class Admin::CalendarController < Admin::AdminController
  def index
    @division = selected_division_or_root
    authorize @division

    # For now, simply honor the currently selected division even if it changes after calendar view
    # first loaded.
    @calendar_events_url = "/admin/calendar_events"
  end
end
