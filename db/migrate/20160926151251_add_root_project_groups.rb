class Loan < ActiveRecord::Base; end

class TimelineEntry < ActiveRecord::Base
  has_closure_tree
end

class ProjectGroup < TimelineEntry; end
class ProjectStep < TimelineEntry; end

class AddRootProjectGroups < ActiveRecord::Migration
  def up
    transaction do
      Loan.all.each do |loan|
        root = ProjectGroup.create(project_type: "Loan", project_id: loan.id)
        ProjectStep.where(project_type: "Loan", project_id: loan.id).each do |step|
          step.parent = root
          step.save(validate: false)
        end
      end
    end
  end
end
