FactoryBot.define do
  factory :accounting_customer, class: 'Accounting::Customer', aliases: [:customer] do
    sequence(:qb_id)
    sequence(:name) { |n| "Customer #{n}" }
  end
end
