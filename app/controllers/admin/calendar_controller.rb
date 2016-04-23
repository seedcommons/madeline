class Admin::CalendarController < Admin::AdminController
  def index
    skip_authorization
  end
end
