class LoanPolicy < ProjectPolicy
  def show?
    user ? super : scope.where(id: record.id).exists?
  end

  def gallery?
    show?
  end

  def old_system_access?
    division_admin(division: Division.root)
  end

  class Scope < DivisionOwnedScope
    def resolve
      user ? super : publicly_visible(scope)
    end

    def publicly_visible(scope)
      public_division_ids = Division.where(public: true).pluck(:id)
      scope.where(division: public_division_ids).active_or_completed.where.not(public_level_value: "hidden")
    end
  end
end
