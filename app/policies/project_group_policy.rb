class ProjectGroupPolicy < ApplicationPolicy

  delegate :persisted?, to: :record

  def duplicate?
    create? && persisted?
  end

  def batch_destroy?
    destroy?
  end

  def adjust_dates?
    update?
  end

  def shift_subsequent?
    update?
  end

  def finalize?
    update?
  end

end
