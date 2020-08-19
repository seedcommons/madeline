# == Schema Information
#
# Table name: accounting_qb_connections
#
#  created_at       :datetime         not null
#  division_id      :integer          not null
#  id               :integer          not null, primary key
#  last_updated_at  :datetime
#  realm_id         :string           not null
#  secret           :string           not null
#  token            :string           not null
#  token_expires_at :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_accounting_qb_connections_on_division_id  (division_id)
#
# Foreign Keys
#
#  fk_rails_...  (division_id => divisions.id)
#

FactoryBot.define do
  factory :accounting_qb_connection, class: 'Accounting::QB::Connection' do
    division { root_division }
    realm_id { 'xxx' }
    access_token { 'xxx' }
    refresh_token { 'xxx' }
    token_expires_at { 180.days.from_now }
  end
end
