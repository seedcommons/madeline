FactoryGirl.define do
  factory :project_group do
    association :project, factory: :loan
    association :agent, factory: :person
    transient_division
    summary { Faker::Lorem.sentence(3, false, 1).chomp(".") }

    factory :root_project_group do
      summary nil

      factory :root_project_group_with_descendants do

        after(:create) do |root|
          create_group = ->(attribs = {}) do
            create(:project_group, attribs.merge(project: root.project, division: root.division))
          end

          # Create 3 top level groups, each with 2-4 subgroups, each with 1-4 child steps
          3.times { root.children << create_group.call }
          root.children.each do |child|
            rand(2..4).times { child.children << create_group.call }
            child.children.each do |grandchild|
              rand(1..4).times do
                grandchild.children << create(:project_step, project: root.project, division: root.division)
              end
            end
          end
        end
      end
    end
  end
end
