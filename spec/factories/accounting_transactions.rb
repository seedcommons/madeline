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

    trait :with_interest do
      loan_transaction_type_value 'interest'
      amount 100

      after(:create) do |txn|
        create(:line_item, parent_transaction: txn, posting_type: 'debit', amount: 100)
        create(:line_item, parent_transaction: txn, posting_type: 'credit', amount: 100)
      end
    end

    trait :with_disbursement do
      loan_transaction_type_value 'disbursement'
      amount 100

      after(:create) do |txn|
        create(:line_item, parent_transaction: txn, posting_type: 'credit', amount: 100)
        create(:line_item, parent_transaction: txn, posting_type: 'debit', amount: 100)
      end
    end

    trait :with_repayment do
      loan_transaction_type_value 'repayment'
      amount 100

      after(:create) do |txn|
        create(:line_item, parent_transaction: txn, posting_type: 'debit', amount: 100)
        create(:line_item, parent_transaction: txn, posting_type: 'credit', amount: 50)
        create(:line_item, parent_transaction: txn, posting_type: 'credit', amount: 50)
      end
    end
  end
end
