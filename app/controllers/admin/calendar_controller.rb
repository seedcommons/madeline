class Admin::CalendarController < Admin::AdminController
  def index
    @division = current_division
    @loans = current_division.loans

    # TODO : All Project Steps for division need to be loaded into an array
  end
end
