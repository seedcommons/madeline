FactoryGirl.define do
  factory :accounting_transaction, class: 'Accounting::Transaction', aliases: [:journal_entry_transaction] do
    sequence(:qb_id)
    qb_transaction_type 'JournalEntry'
    quickbooks_data { {} }
    loan_transaction_type_value %w(interest disbursement repayment).sample
    txn_date { Faker::Date.between(30.days.ago, Date.today) }
    amount { Faker::Number.decimal(4, 2) }
    account
    project
  end
end
