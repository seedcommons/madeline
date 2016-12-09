class UserPolicy < ApplicationPolicy
  def create?
    division_admin
  end

  def update?
    user_is_record? || division_admin
  end

  def show?
    user_is_record? || super
  end

  def destroy?
    division_admin && !user_is_record?
  end

  private

  def user_is_record?
    @user.id == @record.id
  end
end
