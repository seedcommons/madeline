class ProjectStepPolicy < ApplicationPolicy

  def duplicate?
    create?
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
