# == Schema Information
#
# Table name: loans
#
#  id                          :integer          not null, primary key
#  division_id                 :integer
#  organization_id             :integer
#  name                        :string
#  primary_agent_id            :integer
#  secondary_agent_id          :integer
#  amount                      :decimal(, )
#  currency_id                 :integer
#  rate                        :decimal(, )
#  length_months               :integer
#  representative_id           :integer
#  signing_date                :date
#  first_interest_payment_date :date
#  first_payment_date          :date
#  target_end_date             :date
#  projected_return            :decimal(, )
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  organization_snapshot_id    :integer
#  status_value                :string
#  project_type_value          :string
#  loan_type_value             :string
#  public_level_value          :string
#
# Indexes
#
#  index_loans_on_currency_id               (currency_id)
#  index_loans_on_division_id               (division_id)
#  index_loans_on_organization_id           (organization_id)
#  index_loans_on_organization_snapshot_id  (organization_snapshot_id)
#



FactoryGirl.define do
  factory :loan do
    division { root_division }
    organization
    name { "Loan for " + Faker::Company.name }
    association :primary_agent_id, factory: :person
    association :secondary_agent_id, factory: :person
    status_value { ['active', 'frozen', 'liquidated'].sample }
    amount { rand(5000..50000) }
    currency
    rate 0.15
    length_months {rand(1..36) }
    association :representative, factory: :person
    signing_date { Faker::Date.between(Date.civil(2004, 01, 01), Date.today) }
    first_interest_payment_date { Faker::Date.between(signing_date, Date.today) }
    first_payment_date { Faker::Date.between(signing_date, Date.today) }
    target_end_date { Faker::Date.between(first_payment_date, Date.today) }
    projected_return { amount + (amount * rate * length_months/12) }


    trait :active do
      status_value :active
    end

    trait :completed do
      status_value :completed
    end

    #JE todo: fix these

    trait :with_translations do
      after(:create) do |loan|
        create(:translation, remote_table: 'Loans', remote_column_name: 'Description', remote_id: loan.id)
        create(:translation, remote_table: 'Loans', remote_column_name: 'ShortDescription', remote_id: loan.id)
      end
    end

    trait :with_foreign_translations do
      after(:create) do |loan|
        language_id = create(:language, code: 'ES', name: 'Spanish').id
        create(:translation, remote_table: 'Loans', remote_column_name: 'Description', remote_id: loan.id, language: language_id)
        create(:translation, remote_table: 'Loans', remote_column_name: 'ShortDescription', remote_id: loan.id, language: language_id)
      end
    end

    trait :with_loan_media do
      after(:create) do |loan|
        create_list(:media, 5, media_attachable: loan)
      end
    end

    trait :with_coop_media do
      after(:create) do |loan|
        create_list(:media, 5, context_table: 'Cooperatives', context_id: loan.cooperative.id)
      end
    end

    trait :with_log_media do
      with_project_events
      after(:create) do |loan|
        loan.logs.each do |log|
          create_list(:media, 2, context_table: 'ProjectLogs', context_id: log.id)
        end
      end
    end

    trait :with_one_project_event do
      after(:create) do |loan|
        create(:project_event, :with_logs, project_table: 'Loans', project_id: loan.id)
      end
    end

    trait :with_project_events do
      after(:create) do |loan|
        create_list(
          :project_event,
          num_events = 3,
          :with_logs,
          :for_loan,
          loan_id: loan.id
        )
        create(:project_event, :with_logs, :completed, :for_loan, loan_id: loan.id)
      end
    end

    trait :with_repayments do
      after(:create) do |loan|
        paid = create_list(:repayment, num_repayments = 2, :paid, loan_id: loan.id)
        unpaid = create_list(:repayment, num_repayments = 3, loan_id: loan.id)
      end
    end
  end
end
