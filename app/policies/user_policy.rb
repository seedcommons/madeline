class UserPolicy < ApplicationPolicy
  def update?
    user_is_record || super
  end

  def show?
    user_is_record || super
  end

  private

  def user_is_record
    @user.id == @record.id
  end
end
