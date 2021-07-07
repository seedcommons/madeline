class Accounting::TransactionPolicy < ApplicationPolicy
  def index?
    member_level_access = user && user != :machine && user.accessible_division_ids.include?(division.id)
    member_level_access || machine_user_or_appropriate_division_admin?
  end

  def show?
    machine_user_or_appropriate_division_admin?
  end

  def create?
    machine_user_or_appropriate_division_admin? &&
      record.managed? &&
      !record.interest? &&
      read_only_reasons.none?
  end

  def update?
    create?
  end

  def sync?
    create?
  end

  def destroy?
    false
  end

  def read_only_reasons
    # We don't show reasons to people without permission to create transactions because
    # they would not be able to create transactions even if these things were fixed.
    return [] unless machine_user_or_appropriate_division_admin?
    reasons = []
    if qb_division
      reasons << :accounts_not_selected unless qb_division.qb_accounts_selected?
      reasons << :division_transactions_read_only if qb_division.qb_read_only?
    else
      reasons << :qb_not_connected
    end
    reasons << :department_not_set unless division.qb_department?
    reasons << :loan_not_active unless loan.active?
    reasons << :loan_transactions_read_only if loan.txns_read_only?
    reasons
  end

  private

  # Rails 6 will add a private flag for delegate. For now this is what we have.
  private(*delegate(:loan, to: :record))
  private(*delegate(:qb_division, to: :loan))
  private(*delegate(:division, to: :loan))

  def machine_user_or_appropriate_division_admin?
    # If qb_division is nil, it means no valid qb_connection exists on any of division's ancestors.
    # In that case, we check for admin on the current division. This is because in the case where
    # there is no existing QB connection on any ancestor, the current division admin could theoretically
    # connect their division to QuickBooks directly and then create transactions.
    user == :machine || division_admin(division: qb_division || division)
  end
end
