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
          def add_child_group(parent, root)
            parent.children <<
              (group = create(:project_group, project: root.project, division: root.division))
            group
          end

          def add_child_step(parent, root)
            parent.children <<
              (step = create(:project_step, project: root.project, division: root.division))
            step
          end

          def add_child_steps(parent, root)
            rand(1..4).times.map { add_child_step(parent, root) }
          end

          g1 = add_child_group(root, root)
            g1_s = add_child_steps(g1, root)
          g2 = add_child_group(root, root)
            g2_1 = add_child_group(g2, root)
              g2_1_1 = add_child_group(g2_1, root)
                g2_1_1_s = add_child_steps(g2_1_1, root)
              g2_1_2 = add_child_group(g2_1, root)
                g2_1_2_s = add_child_steps(g2_1_2, root)
              g2_1_s = add_child_steps(g2_1, root)
            g2_2 = add_child_group(g2, root)
              g2_2_s = add_child_steps(g2_2, root)
          s3 = add_child_step(root, root)
          g4 = add_child_group(root, root)
        end
      end
    end
  end
end
