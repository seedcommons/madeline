class LoanPolicy < ProjectPolicy
  # TODO: make individual loan pages
  def show?
    if user == :public # public pages, so don't use divisionowned
      record.public_level_value != "hidden" &&
        %w(active completed).include?(record.status_value) &&
        record.division.public
    else # madeline admin, so use divisionowned
      super
    end
  end

  class Scope < DivisionOwnedScope
    def resolve
      if user == :public
        publicly_visible(scope)
      else # madeline admin, so use divisionowned
        super
      end
    end

    def publicly_visible(scope)
      public_division_ids = Division.where(public: true).pluck(:id)
      scope.where(division: public_division_ids).active_or_completed.where.not(public_level_value: "hidden")
    end
  end
end
