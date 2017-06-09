FactoryGirl.define do
  factory :accounting_account, class: 'Accounting::Account' do
    sequence(:qb_id)
    name { Faker::Lorem.word }
  end
end
