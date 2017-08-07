FactoryGirl.define do
  factory :accounting_line_item, class: 'Accounting::LineItem' do
    qb_line_id 1
    association(:accounting_transaction)
    association(:accounting_account)
    posting_type "Credit"
    description "Crediting my account"
    amount "9.99"
  end
end
