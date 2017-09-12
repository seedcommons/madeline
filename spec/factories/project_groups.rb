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

      trait :with_descendants2 do
        after(:create) do |root|
          ProjectGroupFactoryHelper2.create_descendants(root)
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

class ProjectGroupFactoryHelper2
  NODE_NAMES = %i(root g3 g3_s3 g3_s2 g3_s4 g3_s1 g1 g1_s1 g5 g5_s1 g6 g4 g4_s1
    g2 g2_g2 g2_g2_s1 g2_g1 g2_g1_s1 s2 s1)

  # Creates a timeline that sorts as follows:
  #
  # root
  #   g1
  #     g1_s1      (2017-01-01, 5 days)
  #   g2
  #   g2_g1
  #     g2_g1_s1   (2017-01-01, 5 days)
  #   g2_g2
  #     g2_g2_s1   (2017-01-10, 5 days)
  #   g3
  #     g3_s1      (2017-01-01, 10 days)
  #     g3_s2      (2017-02-01, 2 days)
  #     g3_s3      (2017-02-01, 5 days)
  #     g3_s4      (no date, no days)
  #   s1           (2017-02-28, 30 days)
  #   g4
  #     g4_s1      (2017-03-01, 0 days)
  #   g5
  #     g5_s1      (no date, 3 days)
  #   g6
  #     s2         (no date, 0 days)
  #
  # But creates in a jumbled order so that we know sort works properly.
  def self.create_full_timeline
    project = FactoryGirl.create(:loan)
    root = FactoryGirl.create(:root_project_group, project: project)
    create_descendants(root)
  end

  def self.create_descendants(root)
    {}.tap do |nodes|
      nodes[:root] = root
      nodes[:g3] = create_group(nodes[:root])
      nodes[:g3_s3] = create_step(nodes[:g3], "2017-02-01", 5)
      nodes[:g3_s2] = create_step(nodes[:g3], "2017-02-01", 2)
      nodes[:g3_s4] = create_step(nodes[:g3], nil, nil)
      nodes[:g3_s1] = create_step(nodes[:g3], "2017-01-01", 10)
      nodes[:g1] = create_group(nodes[:root])
      nodes[:g1_s1] = create_step(nodes[:g1], "2017-01-01", 5)
      nodes[:g5] = create_group(nodes[:root])
      nodes[:g5_s1] = create_step(nodes[:g5], nil, 3)
      nodes[:g6] = create_group(nodes[:root])
      nodes[:g4] = create_group(nodes[:root])
      nodes[:g4_s1] = create_step(nodes[:g4], "2017-03-01", 0)
      nodes[:g2] = create_group(nodes[:root])
      nodes[:g2_g2] = create_group(nodes[:g2])
      nodes[:g2_g2_s1] = create_step(nodes[:g2_g2], "2017-01-10", 5)
      nodes[:g2_g1] = create_group(nodes[:g2])
      nodes[:g2_g1_s1] = create_step(nodes[:g2_g1], "2017-01-01", 5)
      nodes[:s2] = create_step(nodes[:root], nil, 0)
      nodes[:s1] = create_step(nodes[:root], "2017-02-28", 30)
    end
  end

  def self.create_group(parent)
    FactoryGirl.create(:project_group, project: parent.project, parent: parent).tap do |group|
      parent.children << group
    end
  end

  def self.create_step(parent, scheduled_start_date, scheduled_duration_days)
    FactoryGirl.create(:project_step,
      project: parent.project,
      parent: parent,
      scheduled_start_date: scheduled_start_date,
      scheduled_duration_days: scheduled_duration_days
    ).tap do |step|
      parent.children << step
    end
  end
end
