class ProjectStepPolicy < ApplicationPolicy

  def duplicate_step?
    create?
  end

end
