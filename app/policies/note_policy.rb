class NotePolicy < ApplicationPolicy
  # def create?
  #   notable_class = @record.notable_class.constantize
  #   notable = notable_class.find(@record.notable_id)
  #   policy_class = "#{@record.notable_class}Policy".constantize
  #   policy_class.new(@user, notable).update?
  # end

  def create?
    Pundit.policy(user, record.notable).update?
  end

  def update?
    user == record.author
  end

  def delete?
    user == record.author || division_admin
  end
end
