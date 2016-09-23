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
  factory :project_step do
    association :project, factory: :loan
    association :agent, factory: :person
    scheduled_start_date { Faker::Date.between(Date.civil(2004, 01, 01), Date.today) }
    is_finalized [true, false].sample
    step_type_value { ["step", "milestone"] }
    transient_division
    summary { Faker::Hipster.paragraph }
    details { Faker::Hipster.paragraphs }
    scheduled_duration_days { Faker::Number.between(0, 10) }

    trait :completed do
      actual_end_date { Faker::Date.between(scheduled_start_date, Date.today) }
    end

    trait :past do
      scheduled_start_date { Faker::Date.backward }
    end

    trait :future do
      scheduled_start_date { Faker::Date.forward }
    end

    trait :with_parent do
      before(:create) do |step|
        step.schedule_parent = create :project_step
      end
    end

    trait :with_schedule_tree do
      after(:create) do |step|
        create_list( :project_step, 3, :with_children, schedule_parent: step)
      end
    end

    trait :with_children do
      after(:create) do |step|
        create_list( :project_step, 3, schedule_parent: step)
      end
    end

    trait :with_logs do
      after(:create) do |step|
        create_list(
          :project_log,
          num_logs = 2,
          project_step: step
        )
      end
    end
  end
end
