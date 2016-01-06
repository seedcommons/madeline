FactoryGirl.define do
  factory :project_step do
    # project_table 'Loan'
    # project_id { create(:loan).id }
    project { create(:loan) }
    person
    # need to make sure parent saved before assigning these
    # summary { Faker::Lorem.sentence }
    # details { Faker::Lorem.paragraph }
    scheduled_date { Faker::Date.between(Date.civil(2004, 01, 01), Date.today) }
    completed_date { Faker::Date.between(Date.civil(2004, 01, 01), Date.today) }
    is_finalized [true,false].sample  ##JE todo: is ther a better pattern to assign a boolean?
    type_option_id { ProjectStep::TYPE_OPTIONS.values.sample }

    trait :completed do
      completed_date { Faker::Date.between(date, Date.today) }
    end

    trait :past do
      scheduled_date { Faker::Date.backward }
    end

    trait :future do
      scheduled_date { Faker::Date.forward }
    end

    # is this even valid?
    # trait :for_loan do
    #   transient { loan_id 0 }
    #   after(:build) do |event, evaluator|
    #     event.project_table = 'Loans'
    #     event.project_id = evaluator.loan_id
    #   end
    # end

    trait :with_logs do
      after(:create) do |step|
        create_list(
          :project_log,
          num_logs = 2,
          project_step: step
          # paso_id: event.id,
          # project_id: event.project_id,
          # project_table: event.project_table
        )
      end
    end
  end
end
