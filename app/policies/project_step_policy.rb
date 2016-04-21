class ProjectStepPolicy < ApplicationPolicy

  def duplicate?
    create?
  end

end
