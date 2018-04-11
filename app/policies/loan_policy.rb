class LoanPolicy < ProjectPolicy
  def show?
    user ? super : scope.where(id: record.id).exists? && scope.where(public_level_value: 'featured').exists?
  end
  
  def gallery?
    show?
  end

  class Scope < DivisionOwnedScope
    def resolve
      user ? super : scope.where(public_level_value: 'featured')
    end
  end
end
