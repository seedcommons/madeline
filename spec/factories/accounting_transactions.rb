FactoryGirl.define do
  factory :accounting_transaction, class: 'Accounting::Transaction' do
    sequence(:qb_transaction_id)
    qb_transaction_type { Accounting::Transaction::TRANSACTION_TYPES.sample }
  end
end
