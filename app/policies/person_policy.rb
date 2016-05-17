class PersonPolicy < ApplicationPolicy

  def update_access?
    division_admin
  end

  def update_password?
    user_is_record? || division_admin
  end

  # For People associated with User records, restrict updates to email to admins or self.
  # JE Todo 3776: Confirm if all fields should be locked, or just email?
  def update_email?
    !@record.user || user_is_record? || division_admin
  end

  private

  def user_is_record?
    @record.user && @user && @user.id != nil && @record.user.id == @user.id
  end

  class Scope < DivisionOwnedScope
  end
end
