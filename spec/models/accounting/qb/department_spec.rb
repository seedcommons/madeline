# == Schema Information
#
# Table name: accounting_qb_departments
#
#  id              :bigint           not null, primary key
#  name            :string           not null
#  quickbooks_data :json
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  division_id     :bigint
#  qb_id           :string           not null
#
# Indexes
#
#  index_accounting_qb_departments_on_division_id  (division_id)
#
# Foreign Keys
#
#  fk_rails_...  (division_id => divisions.id)
#

require 'rails_helper'

RSpec.describe Accounting::QB::Department, type: :model do
end
