FactoryGirl.define do
  factory :accounting_account, class: 'Accounting::Account', aliases: [:account] do
    sequence(:qb_id)
    sequence(:name) { |n| "Account #{n}" }
    qb_account_classification 'Asset'
  end
end
