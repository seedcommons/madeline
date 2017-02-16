class Admin::DashboardController < Admin::AdminController
  def dashboard
    authorize :dashboard
    @person = Person.find(current_user.profile_id)
    prep_calendar
  end

  private

  def prep_calendar
    @division = current_division
    @calendar_events_url = "/admin/calendar_events?person_id=#{@person.id}"
  end
end
