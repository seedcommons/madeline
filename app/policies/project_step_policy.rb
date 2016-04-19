class ProjectStepPolicy < ApplicationPolicy

  #todo: confirm if there is a better way to define these aliases

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
