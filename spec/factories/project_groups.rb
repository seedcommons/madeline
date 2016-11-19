# == Schema Information
#
# Table name: project_steps
#
#  id              :integer          not null, primary key
#  project_id      :integer
#  project_type    :string
#  agent_id        :integer
#  scheduled_date  :date
#  actual_end_date  :date
#  is_finalized    :boolean
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  step_type_value :string
#
# Indexes
#
#  index_project_steps_on_agent_id                     (agent_id)
#  index_project_steps_on_project_type_and_project_id  (project_type,project_id)
#

FactoryGirl.define do
  factory :project_group do |f|

    association :project, factory: :loan
    association :agent, factory: :person
    transient_division
    summary { Faker::Lorem.sentence(3, false, 1).chomp(".") }

    factory :root_project_group do
      summary nil

      trait :with_descendants do
        after(:create) do |root|
          helper = ProjectGroupFactoryHelper
          g1 = helper.add_child_group(root, root)
            g1_s = helper.add_child_steps(g1, root)
          g2 = helper.add_child_group(root, root)
            g2_1 = helper.add_child_group(g2, root)
              g2_1_1 = helper.add_child_group(g2_1, root)
                g2_1_1_s = helper.add_child_steps(g2_1_1, root)
              g2_1_2 = helper.add_child_group(g2_1, root)
                g2_1_2_s = helper.add_child_steps(g2_1_2, root)
              g2_1_s = helper.add_child_steps(g2_1, root)
            g2_2 = helper.add_child_group(g2, root)
              g2_2_s = helper.add_child_steps(g2_2, root)
          s3 = helper.add_child_step(root, root)
          g4 = helper.add_child_group(root, root)
        end
      end

      trait :with_only_step_descendants do
        after(:create) do |root|
          helper = ProjectGroupFactoryHelper
          helper.add_child_steps(root, root, 5..10)
        end
      end
    end
  end
end

class ProjectGroupFactoryHelper
  def self.add_child_group(parent, root)
    parent.children <<
      (group = FactoryGirl.create(:project_group,
        project: root.project,
        division: root.division,
        parent_id: parent.id)
      )
    group
  end

  def self.add_child_step(parent, root)
    attribs = {}

    # Randomly sometimes don't include dates.
    attribs[:scheduled_start_date] = nil if rand(5) == 0

    step = FactoryGirl.create(:project_step, attribs.merge(project: root.project, division: root.division))
    parent.children << step
    step
  end

  def self.add_child_steps(parent, root, rand_range = 1..4)
    rand(rand_range).times.map { add_child_step(parent, root) }
  end
end
