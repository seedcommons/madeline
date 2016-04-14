class DashboardPolicy < ApplicationPolicy
  def index?
    @user.present?
  end
end
