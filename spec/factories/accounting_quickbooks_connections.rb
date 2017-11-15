FactoryGirl.define do
  factory :accounting_quickbooks_connection, class: 'Accounting::Quickbooks::Connection' do
    division { root_division }
    realm_id 'xxx'
    secret 'xxx'
    token 'xxx'
    token_expires_at { 180.days.from_now }
  end
end
