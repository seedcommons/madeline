class LoanPolicy < ProjectPolicy
  def show?
    user ? super : scope.where(id: record.id).exists? && scope.visible.exists?
  end
  
  def gallery?
    show?
  end

  class Scope < DivisionOwnedScope
    def resolve
      user ? super : scope.visible
    end
  end
end
