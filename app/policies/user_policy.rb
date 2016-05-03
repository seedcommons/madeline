class UserPolicy < ApplicationPolicy
  def index?
    any_division_admin?
  end

  def create?
    division_admin
  end

  def update?
    user_is_record? || division_admin
  end

  def show?
    user_is_record? || super
  end

  private

  def user_is_record?
    @user.id == @record.id
  end
end
