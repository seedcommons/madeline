# == Schema Information
#
# Table name: accounting_accounts
#
#  created_at    :datetime         not null
#  id            :integer          not null, primary key
#  name          :string           not null
#  project_id    :integer
#  qb_account_id :string           not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_accounting_accounts_on_project_id     (project_id)
#  index_accounting_accounts_on_qb_account_id  (qb_account_id)
#
# Foreign Keys
#
#  fk_rails_225f9a7d43  (project_id => projects.id)
#

class Accounting::Account < ActiveRecord::Base
  belongs_to :project

  has_many :transactions, inverse_of: :account, foreign_key: :accounting_account_id, dependent: :destroy
end
