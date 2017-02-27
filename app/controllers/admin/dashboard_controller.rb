class Admin::DashboardController < Admin::AdminController
  def dashboard
    authorize :dashboard
    @person = Person.find(current_user.profile_id)
    prep_calendar
    prep_logs
  end

  private

  def prep_calendar
    @division = current_division
    @calendar_events_url = "/admin/calendar_events?person_id=#{@person.id}"
  end

  def prep_logs
    @context = "dashboard"
    @logs = ProjectLog.in_division(selected_division).where(agent_id: @person.id).by_date.page(1).
      per(10)
  end
end
