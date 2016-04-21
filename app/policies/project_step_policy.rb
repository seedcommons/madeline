class ProjectStepPolicy < ApplicationPolicy

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
