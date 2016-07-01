class NotePolicy < ApplicationPolicy
  # def create?
  #   notable_class = @record.notable_class.constantize
  #   notable = notable_class.find(@record.notable_id)
  #   policy_class = "#{@record.notable_class}Policy".constantize
  #   policy_class.new(@user, notable).update?
  # end
end
