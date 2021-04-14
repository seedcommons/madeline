class Accounting::TransactionPolicy < ApplicationPolicy
  def index?
    false
  end

  def show?
    machine_user_or_qb_division_admin?
  end

  def create?
    machine_user_or_qb_division_admin? && read_only_reasons.none?
  end

  def update?
    create?
  end

  def destroy?
    false
  end

  def read_only_reasons
    return [] unless machine_user_or_qb_division_admin?
    reasons = []
    reasons << :accounts_not_selected unless qb_division&.qb_accounts_selected?
    reasons << :division_transactions_read_only if qb_division&.qb_read_only?
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

  def machine_user_or_qb_division_admin?
    user == :machine || division_admin(division: division)
  end
end
