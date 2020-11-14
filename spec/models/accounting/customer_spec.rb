# == Schema Information
#
# Table name: accounting_customers
#
#  id              :bigint           not null, primary key
#  name            :string           not null
#  quickbooks_data :json
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  qb_id           :string           not null
#

require 'rails_helper'

RSpec.describe Accounting::Customer, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
