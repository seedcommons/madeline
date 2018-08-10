class NotePolicy < ApplicationPolicy
  def create?
    Pundit.policy(user, record.notable).update?
  end

  def update?
    user == record.author.try(:user)
  end

  def destroy?
    user == record.author.try(:user) || division_admin
  end
end
