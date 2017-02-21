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
    options = {}
    @logs = ProjectLog.in_division(selected_division).filter_by(options).
        order('date IS NULL, date DESC, created_at DESC').
        page(1).per(10)
  end
end
