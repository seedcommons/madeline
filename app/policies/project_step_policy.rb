class ProjectStepPolicy < ApplicationPolicy

  delegate :persisted?, to: :record

  def duplicate?
    create? && persisted?
  end

  def show_duplicate?
    true
  end

  def batch_destroy?
    destroy?
  end

  def adjust_dates?
    update?
  end

  def finalize?
    update?
  end

end
