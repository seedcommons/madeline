FactoryBot.define do
  factory :accounting_qb_connection, class: 'Accounting::QB::Connection' do
    division { root_division }
    realm_id { 'xxx' }
    access_token { 'xxx' }
    last_updated_at { Time.current }
    refresh_token { 'xxx' }
    token_expires_at { 180.days.from_now }
  end
end
