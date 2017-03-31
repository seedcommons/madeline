FactoryGirl.define do
  factory :accounting_transaction, class: 'Accounting::Transaction' do
    sequence(:qb_id)
    qb_transaction_type { Accounting::Transaction::TRANSACTION_TYPES.sample }
    quickbooks_data { {} }
  end
end
