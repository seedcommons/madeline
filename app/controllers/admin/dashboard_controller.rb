class Admin::DashboardController < Admin::AdminController
  def dashboard
    authorize Project
    authorize Person
    @person = Person.find(current_user.profile_id)
    prep_calendar
  end

  private

  def prep_calendar
    @division = current_division
    authorize @division
    @calendar_events_url = "/admin/calendar_events"
  end
end
