FactoryGirl.define do
  factory :accounting_transaction, class: 'Accounting::Transaction' do
    sequence(:qb_id)
    qb_transaction_type { Accounting::Transaction::QB_TRANSACTION_TYPES.sample }
    quickbooks_data { {} }
  end

  factory :journal_entry, class: 'Accounting::Transaction' do
    sequence(:qb_id)
    qb_transaction_type { 'JournalEntry' }
    quickbooks_data { {} }
  end
end
