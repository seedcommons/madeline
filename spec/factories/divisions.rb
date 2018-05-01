# == Schema Information
#
# Table name: divisions
#
#  accent_fg_color                :string
#  accent_main_color              :string
#  banner_bg_color                :string
#  banner_fg_color                :string
#  created_at                     :datetime         not null
#  currency_id                    :integer
#  custom_data                    :json
#  description                    :text
#  id                             :integer          not null, primary key
#  interest_income_account_id     :integer
#  interest_receivable_account_id :integer
#  internal_name                  :string
#  locales                        :json
#  logo_content_type              :string
#  logo_file_name                 :string
#  logo_file_size                 :integer
#  logo_text                      :string
#  logo_updated_at                :datetime
#  name                           :string
#  notify_on_new_logs             :boolean          default(FALSE)
#  organization_id                :integer
#  parent_id                      :integer
#  principal_account_id           :integer
#  public                         :boolean          default(FALSE), not null
#  qb_id                          :string
#  short_name                     :string
#  updated_at                     :datetime         not null
#
# Indexes
#
#  index_divisions_on_currency_id                     (currency_id)
#  index_divisions_on_interest_income_account_id      (interest_income_account_id)
#  index_divisions_on_interest_receivable_account_id  (interest_receivable_account_id)
#  index_divisions_on_organization_id                 (organization_id)
#  index_divisions_on_principal_account_id            (principal_account_id)
#  index_divisions_on_short_name                      (short_name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (currency_id => currencies.id)
#  fk_rails_...  (interest_income_account_id => accounting_accounts.id)
#  fk_rails_...  (interest_receivable_account_id => accounting_accounts.id)
#  fk_rails_...  (organization_id => organizations.id)
#  fk_rails_...  (principal_account_id => accounting_accounts.id)
#

def root_division
  Division.root
end

FactoryBot.define do
  factory :division do
    description { Faker::Lorem.sentence }
    name { Faker::Address.city }
    parent { root_division }
    sequence(:short_name) { |n| "#{Faker::Lorem.word}-#{n}" }

    trait :with_accounts do
      association :principal_account, factory: :accounting_account
      association :interest_receivable_account, factory: :accounting_account
      association :interest_income_account, factory: :accounting_account

      after(:create) do |division|
        # This is needed for Division#qb_division to work properly
        division.qb_connection = create(:accounting_quickbooks_connection, division: division)
      end
    end
  end
end

# Defines a global trait for models that delegate their divisions
# allowing us to assign them directly
FactoryBot.define do
  trait :transient_division do
    transient do
      division { nil }
    end

    after(:create) do |instance, evaluator|
      instance.division = evaluator.division if evaluator.division.present?
    end
  end
end
