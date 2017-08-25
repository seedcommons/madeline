FactoryGirl.define do
  factory :accounting_line_item, class: 'Accounting::LineItem', aliases: [:line_item] do
    qb_line_id 1
    association :parent_transaction, factory: :accounting_transaction
    association :account
    posting_type ["credit", "debit"].sample
    description { Faker::Hipster.sentence(4).chomp(".") }
    amount { Faker::Number.decimal(4, 2) }
  end
end
