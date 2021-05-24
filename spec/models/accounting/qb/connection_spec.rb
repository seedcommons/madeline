# == Schema Information
#
# Table name: accounting_qb_connections
#
#  access_token     :string
#  created_at       :datetime         not null
#  division_id      :integer          not null
#  id               :integer          not null, primary key
#  last_updated_at  :datetime
#  realm_id         :string           not null
#  refresh_token    :string
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

require 'rails_helper'

describe Accounting::QB::Connection, type: :model do
  # need to know that connected? returns true if  it's not expired,
  # no invalid grant

  # if time, stub OAuth2::AccessToken refresh & test that. 
end
