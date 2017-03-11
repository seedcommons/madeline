FactoryGirl.define do
  factory :project_step do
    association :project, factory: :loan
    association :agent, factory: :person
    scheduled_start_date { Faker::Date.between(Date.civil(2014, 01, 01), Date.today) }
    scheduled_duration_days { Faker::Number.between(0, 10) }
    is_finalized { [true, false].sample }
    step_type_value { ["step", "milestone"].sample }
    transient_division
    summary { Faker::Hipster.sentence(4).chomp(".") }
    details { Faker::Hipster.paragraph }

    trait :completed do
      actual_end_date { Faker::Date.between(scheduled_start_date, Date.today) }
    end

    trait :past do
      scheduled_start_date { Faker::Date.backward }
    end

    trait :past_due do
      scheduled_start_date { Faker::Date.between(30.days.ago, 15.day.ago) }
      scheduled_duration_days { rand(1..14) }
    end

    trait :open do
      scheduled_start_date { Faker::Date.between(30.days.ago, 15.day.ago) }
      scheduled_duration_days { nil }
    end

    trait :future do
      scheduled_start_date { Faker::Date.forward }
    end

    trait :with_non_root_parent do
      before(:create) do |step|
        root = create(:root_project_group)
        group = create(:project_group, project: root.project, parent: root)
        step.parent = group
        step.project = root.project
      end
    end

    trait :with_schedule_tree do
      after(:create) do |step|
        create_list(:project_step, 3, :with_children, schedule_parent: step)
      end
    end

    trait :with_children do
      after(:create) do |step|
        create_list(:project_step, 3, schedule_parent: step)
      end
    end

    trait :with_logs do
      after(:create) do |step|
        create_list(:project_log, num_logs = 2, project_step: step)
      end
    end

    trait :with_old_logs do
      after(:create) do |step|
        create_list(:project_log, num_logs = 2, :old, project_step: step)
      end
    end

    trait :with_recent_logs do
      after(:create) do |step|
        create_list(:project_log, num_logs = 2, :recent, project_step: step)
      end
    end
  end
end
