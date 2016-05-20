class PersonPolicy < ApplicationPolicy

  # Make records assocaited with a user record read only except for admins or self.
  def update?
    user_is_record? || (@record.has_system_access? ? division_admin : division_member_or_admin)
  end

  def update_access?
    division_admin
  end

  def update_password?
    user_is_record? || division_admin
  end

  private

  def user_is_record?
    @user == @record.user
  end

  class Scope < DivisionOwnedScope
  end
end
