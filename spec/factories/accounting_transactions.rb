FactoryGirl.define do
  factory :accounting_transaction, class: 'Accounting::Transaction', aliases: [:journal_entry_transaction] do
    sequence(:qb_id)
    # All Madeline-related transactions are Journal Entries now
    # qb_transaction_type { Accounting::Transaction::QB_TRANSACTION_TYPES.sample }
    qb_transaction_type 'JournalEntry'
    quickbooks_data { {} }
    loan_transaction_type %w(disbursement repayment).sample
    txn_date { Faker::Date.between(30.days.ago, Date.today) }
    amount { Faker::Number.decimal(4, 2) }
    account
    project
  end

  # factory :journal_entry_transaction, class: 'Accounting::Transaction' do
  #   sequence(:qb_id)
  #   qb_transaction_type 'JournalEntry'
  #   quickbooks_data { {} }
  # end
end
