class PublicLoanPolicy < LoanPolicy
  def show?
    scope.where(id: record.id).exists?
  end

  def gallery?
    show?
  end

  class Scope
    def resolve
      publicly_visible(scope)
    end

    def publicly_visible(scope)
      public_division_ids = Division.where(public: true).pluck(:id)
      scope.where(division: public_division_ids).active_or_completed.where.not(public_level_value: "hidden")
    end
  end
end
