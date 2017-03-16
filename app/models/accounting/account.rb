# == Schema Information
#
# Table name: accounting_accounts
#
#  created_at                :datetime         not null
#  id                        :integer          not null, primary key
#  name                      :string           not null
#  qb_account_classification :string
#  qb_id                     :string           not null
#  quickbooks_data           :json
#  updated_at                :datetime         not null
#
# Indexes
#
#  index_accounting_accounts_on_qb_id  (qb_id)
#

class Accounting::Account < ActiveRecord::Base
  belongs_to :project

  has_many :transactions, inverse_of: :account, foreign_key: :accounting_account_id, dependent: :destroy
end
