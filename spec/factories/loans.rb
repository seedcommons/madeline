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
#  status_option_id            :integer
#  project_type_option_id      :integer
#  loan_type_option_id         :integer
#  public_level_option_id      :integer
#  organization_snapshot_id    :integer
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
    division
    association :organization, :with_country
    name { 'Loan for ' + Faker::Company.name }
    association :primary_agent_id, factory: :person
    association :secondary_agent_id, factory: :person
    status_option_id { [1,2].sample }
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
      status_option_id Loan::STATUS_OPTIONS.value_for('active')
    end

    trait :completed do
      status_option_id Loan::STATUS_OPTIONS.value_for('completed')
    end

    #JE todo: fix these

    trait :with_translations do
      after(:create) do |loan|
        create(:translation, translatable: loan, translatable_attribute: 'details')
        create(:translation, translatable: loan, translatable_attribute: 'summary')
      end
    end

    trait :with_foreign_translations do
      after(:create) do |loan|
        language = create(:language, code: 'ES', name: 'Spanish')
        create(:translation, translatable: loan, translatable_attribute: 'details', language: language)
        create(:translation, translatable: loan, translatable_attribute: 'summary', language: language)
      end
    end

    trait :with_loan_media do
      after(:create) do |loan|
        create_list(:media, 5, media_attachable: loan)
      end
    end

    trait :with_coop_media do
      after(:create) do |loan|
        create_list(:media, 5, media_attachable: loan.organization)
      end
    end

    trait :with_log_media do
      with_project_steps
      after(:create) do |loan|
        loan.logs.each do |log|
          create_list(:media, 2, media_attachable: log)
        end
      end
    end

    trait :with_one_project_step do
      after(:create) do |loan|
        create(:project_step, :with_logs, project: loan)
      end
    end

    trait :with_project_steps do
      after(:create) do |loan|
        create_list(
          :project_step,
          num_steps = 3,
          :with_logs,
          project: loan
        )
        create(:project_step, :with_logs, :completed, project: loan)
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
