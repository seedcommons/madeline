class NotePolicy < ApplicationPolicy
  def create?
    Pundit.policy(user, record.notable).update?
  end

  def update?
    user == record.author.user
  end

  def delete?
    user == record.author.user || division_admin
  end
end
