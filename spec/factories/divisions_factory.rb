# == Schema Information
#
# Table name: divisions
#
#  id                             :integer          not null, primary key
#  accent_fg_color                :string
#  accent_main_color              :string
#  banner_bg_color                :string
#  banner_fg_color                :string
#  closed_books_date              :date
#  custom_data                    :json
#  description                    :text
#  internal_name                  :string
#  locales                        :json
#  logo                           :string
#  logo_content_type              :string
#  logo_file_name                 :string
#  logo_file_size                 :integer
#  logo_text                      :string
#  logo_updated_at                :datetime
#  name                           :string
#  notify_on_new_logs             :boolean          default(FALSE)
#  public                         :boolean          default(FALSE), not null
#  qb_read_only                   :boolean          default(TRUE), not null
#  short_name                     :string
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  currency_id                    :integer
#  interest_income_account_id     :integer
#  interest_receivable_account_id :integer
#  organization_id                :integer
#  parent_id                      :integer
#  principal_account_id           :integer
#  qb_parent_class_id             :string
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
    public { true }

    trait :with_accounts do
      principal_account { create(:accounting_account, name: "Principal Account #{rand(1..9999)}") }
      interest_receivable_account { create(:accounting_account, name: "Interest Receivable #{rand(1..9999)}") }
      interest_income_account { create(:accounting_account, name: "Interest Income #{rand(1..9999)}") }

      # This is needed for Division#qb_division to work properly
      with_qb_connection
    end

    trait :with_qb_dept do
      qb_department { create(:department) }
    end

    trait :with_qb_connection do
      after(:create) do |division|
        division.qb_connection = create(:accounting_qb_connection, division: division, last_updated_at: Time.current)
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
