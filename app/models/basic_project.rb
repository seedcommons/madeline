# == Schema Information
#
# Table name: projects
#
#  amount                      :decimal(, )
#  created_at                  :datetime         not null
#  currency_id                 :integer
#  custom_data                 :json
#  division_id                 :integer
#  first_interest_payment_date :date
#  first_payment_date          :date
#  id                          :integer          not null, primary key
#  length_months               :integer
#  loan_type_value             :string
#  name                        :string
#  organization_id             :integer
#  primary_agent_id            :integer
#  project_type_value          :string
#  projected_return            :decimal(, )
#  public_level_value          :string
#  rate                        :decimal(, )
#  representative_id           :integer
#  secondary_agent_id          :integer
#  signing_date                :date
#  status_value                :string
#  target_end_date             :date
#  type                        :string           not null
#  updated_at                  :datetime         not null
#
# Indexes
#
#  index_projects_on_currency_id      (currency_id)
#  index_projects_on_division_id      (division_id)
#  index_projects_on_organization_id  (organization_id)
#
# Foreign Keys
#
#  fk_rails_5a4bc9458a  (division_id => divisions.id)
#  fk_rails_7a8d917bd9  (secondary_agent_id => people.id)
#  fk_rails_ade0930898  (currency_id => currencies.id)
#  fk_rails_dc1094f4ed  (organization_id => organizations.id)
#  fk_rails_ded298065b  (representative_id => people.id)
#  fk_rails_e90f6505d8  (primary_agent_id => people.id)
#

class BasicProject < Project
  scope :status, ->(status) { where(status: status) }
  attr_option_settable :status

  def start_date
    signing_date
  end

  def default_name
    I18n.t("common.untitled")
  end

  def display_name
    name.defined? ? name: display_name
  end
end
