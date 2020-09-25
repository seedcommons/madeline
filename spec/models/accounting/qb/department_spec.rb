# == Schema Information
#
# Table name: accounting_qb_departments
#
#  created_at      :datetime         not null
#  division_id     :bigint(8)
#  id              :bigint(8)        not null, primary key
#  name            :string           not null
#  qb_id           :string           not null
#  quickbooks_data :json
#  updated_at      :datetime         not null
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
