FactoryBot.define do
  factory :loan, aliases: [:project] do
    division { root_division }
    organization
    name { "Loan for " + organization.name }
    currency { Currency.all.sample || create(:currency) }
    association :primary_agent, factory: :person
    association :secondary_agent, factory: :person
    status_value { ["active", "frozen", "liquidated", "completed"].sample }
    loan_type_value { ["liquidity_loc", "investment_loc", "investment", "evolving", "single_liquidity_loc", "wc_investment", "sa_investment"].sample }
    public_level_value { ["featured", "hidden", "public"].sample }
    amount { rand(5000..50000) }
    rate { BigDecimal(rand(0..80)) / 2 } # Rates are usually integers, occasionally X.5
    length_months { rand(1..36) }
    association :representative, factory: :person
    signing_date { Faker::Date.between(Date.civil(2004, 01, 01), Date.today) }
    projected_first_interest_payment_date { signing_date ? Faker::Date.between(signing_date, Date.today) : Date.today }
    actual_first_payment_date { signing_date ? Faker::Date.between(signing_date, Date.today) : Date.today }
    projected_end_date { Faker::Date.between(actual_first_payment_date, Date.today) }
    projected_return { amount + (amount * rate * length_months/12) }

    trait :featured do
      public_level_value { "featured" }
    end

    trait :public do
      public_level_value { "public" }
    end

    trait :active do
      status_value { :active }
    end

    trait :completed do
      status_value { :completed }
    end

    trait :prospective do
      status_value { :prospective }
    end

    trait :with_translations do
      summary { Faker::Hipster.sentence }
      details { Faker::Hipster.paragraph }
    end

    trait :with_foreign_translations do
      summary_es { Faker::Lorem.sentence }
      details_es { Faker::Lorem.paragraph(2) }
    end

    trait :with_loan_media do
      after(:create) do |loan|
        create_list(:media, rand(1..5), media_attachable: loan)
      end
    end

    trait :with_contract do
      after(:create) do |loan|
        create(:media, :contract, media_attachable: loan)
      end
    end

    trait :with_coop_media do
      after(:create) do |loan|
        create_list(:media, rand(1..5), media_attachable: loan.organization)
      end
    end

    trait :with_one_project_step do
      after(:create) do |loan|
        step = create(:project_step, :with_logs, project: loan)
        loan.root_timeline_entry.children << step
      end
    end

    trait :with_past_due_project_step do
      after(:create) do |loan|
        step = create(:project_step, :past_due, :with_logs, project: loan)
        loan.root_timeline_entry.children << step
      end
    end

    trait :with_open_project_step do
      after(:create) do |loan|
        step = create(:project_step, :open, :with_logs, project: loan)
        loan.root_timeline_entry.children << step
      end
    end

    trait :with_timeline do
      after(:create) do |loan|
        create(:root_project_group, :with_descendants, project: loan)
      end
    end

    trait :with_steps_only_timeline do
      after(:create) do |loan|
        create(:root_project_group, :with_only_step_descendants, project: loan)
      end
    end

    trait :with_a_number_of_recent_project_steps do
      transient do
        step_count { 5 }
      end

      after(:create) do |loan, evaluator|
        step = create_list(:project_step, evaluator.step_count, :recent, :with_logs, project: loan)
        loan.root_timeline_entry.children << step
      end
    end

    trait :with_a_number_of_old_project_steps do
      transient do
        old_step_count { 5 }
      end

      after(:create) do |loan, evaluator|
        create_list(:project_step, evaluator.old_step_count, :old, :with_logs, project: loan)
      end
    end

    # Will only work if the loan has steps.
    trait :with_log_media do
      after(:create) do |loan|
        loan.logs.each do |log|
          create_list(:media, rand(1..3), media_attachable: log)
        end
      end
    end

    trait :with_repayments do
      after(:create) do |loan|
        # TODO: Tie to accounting system
        # paid = create_list(:repayment, num_repayments = 2, :paid, loan_id: loan.id)
        # unpaid = create_list(:repayment, num_repayments = 3, loan_id: loan.id)
      end
    end

    trait :with_transaction do
      after(:create) do |loan|
        create(:accounting_transaction, project_id: loan.id)
      end
    end

    trait :with_recent_logs do
      after(:create) do |loan|
        create(:project_step, :open, :with_recent_logs, project: loan)
      end
    end

    trait :with_old_logs do
      after(:create) do |loan|
        create(:project_step, :open, :with_old_logs, project: loan)
      end
    end

    trait :with_accounting_transaction do
      after(:create) do |loan|
        create(:accounting_transaction, project: loan)
      end
    end

    # Assumes a LoanQuestionSet with name 'loan_criteria' and questions `summary` and `workers` exists.
    trait :with_criteria_responses do |loan|
      after(:create) do |loan|
        create(:response_set,
          kind: 'loan_criteria',
          loan: loan,
          custom_data: {summary: 'foo', workers: 5}
        )

      end
    end
  end
end
