FactoryGirl.define do
  factory :accounting_transaction, class: 'Accounting::Transaction', aliases: [:journal_entry_transaction] do
    # division is not an attribute here but we need to access the accounts associated
    # this is only for some traits below
    transient do
      division nil
    end

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
      amount 3

      after(:create) do |txn, evaluator|
        create(:line_item, parent_transaction: txn, account: evaluator.division.interest_receivable_account,
          posting_type: 'debit', amount: evaluator.amount)
        create(:line_item, parent_transaction: txn, account: evaluator.division.interest_income_account,
          posting_type: 'credit', amount: evaluator.amount)
      end
    end

    trait :with_disbursement do
      loan_transaction_type_value 'disbursement'
      amount 100

      after(:create) do |txn, evaluator|
        create(:line_item, parent_transaction: txn, account: txn.account,
          posting_type: 'credit', amount: evaluator.amount)
        create(:line_item, parent_transaction: txn, account: evaluator.division.principal_account,
          posting_type: 'debit', amount: evaluator.amount)
      end
    end

    trait :with_repayment do
      loan_transaction_type_value 'repayment'
      amount 23.7

      after(:create) do |txn, evaluator|
        create(:line_item, parent_transaction: txn, account: txn.account,
          posting_type: 'debit', amount: evaluator.amount)
        create(:line_item, parent_transaction: txn, account: evaluator.division.interest_receivable_account,
          posting_type: 'credit', amount: evaluator.amount.to_f/2)
        create(:line_item, parent_transaction: txn, account: evaluator.division.principal_account,
          posting_type: 'credit', amount: evaluator.amount.to_f/2)
      end
    end
  end
end
