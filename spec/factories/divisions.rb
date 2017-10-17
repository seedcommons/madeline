# == Schema Information
#
# Table name: divisions
#
#  accent_fg_color    :string
#  accent_main_color  :string
#  banner_bg_color    :string
#  banner_fg_color    :string
#  created_at         :datetime         not null
#  currency_id        :integer
#  custom_data        :json
#  description        :text
#  id                 :integer          not null, primary key
#  internal_name      :string
#  locales            :json
#  logo_content_type  :string
#  logo_file_name     :string
#  logo_file_size     :integer
#  logo_text          :string
#  logo_updated_at    :datetime
#  name               :string
#  notify_on_new_logs :boolean          default(FALSE)
#  organization_id    :integer
#  parent_id          :integer
#  quickbooks_data    :json
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_divisions_on_currency_id      (currency_id)
#  index_divisions_on_organization_id  (organization_id)
#
# Foreign Keys
#
#  fk_rails_648c512956  (organization_id => organizations.id)
#  fk_rails_99cb2ea4ed  (currency_id => currencies.id)
#

def root_division
  Division.root
end

FactoryGirl.define do
  factory :division do
    description { Faker::Lorem.sentence }
    name { Faker::Company.name }
    parent { root_division }

    trait :with_accounts do
      association :principal_account, factory: :accounting_account
      association :interest_receivable_account, factory: :accounting_account
      association :interest_income_account, factory: :accounting_account
    end
  end
end

# Defines a global trait for models that delegate their divisions
# allowing us to assign them directly
FactoryGirl.define do
  trait :transient_division do
    transient do
      division { nil }
    end

    after(:create) do |instance, evaluator|
      instance.division = evaluator.division if evaluator.division.present?
    end
  end
end
