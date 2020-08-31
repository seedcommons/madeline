# == Schema Information
#
# Table name: accounting_customers
#
#  created_at      :datetime         not null
#  id              :bigint(8)        not null, primary key
#  name            :string           not null
#  qb_id           :string           not null
#  quickbooks_data :json
#  updated_at      :datetime         not null
#

require 'rails_helper'

RSpec.describe Accounting::QB::Vendor, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
