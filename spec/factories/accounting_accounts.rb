FactoryGirl.define do
  factory :accounting_account, class: 'Accounting::Account', aliases: [:account] do
    sequence(:qb_id)
    name { Faker::Lorem.word }
    qb_account_classification 'Asset'
  end
end
