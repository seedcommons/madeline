class ProjectDuplicator
  attr_reader :project_to_copy

  def initialize(project_to_copy)
    @project_to_copy = project_to_copy
  end

  def duplicate
    copy = project_to_copy.amoeba_dup
    copy.original = project_to_copy

    copy.save!
    copy
  end
end
