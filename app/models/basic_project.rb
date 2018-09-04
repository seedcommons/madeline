# == Schema Information
#
# Table name: projects
#
#  actual_first_payment_date             :date
#  amount                                :decimal(, )
#  created_at                            :datetime         not null
#  currency_id                           :integer
#  custom_data                           :json
#  division_id                           :integer          not null
#  id                                    :integer          not null, primary key
#  length_months                         :integer
#  loan_type_value                       :string
#  name                                  :string
#  organization_id                       :integer
#  original_id                           :integer
#  primary_agent_id                      :integer
#  projected_end_date                    :date
#  projected_first_interest_payment_date :date
#  projected_return                      :decimal(, )
#  public_level_value                    :string           not null
#  rate                                  :decimal(, )
#  representative_id                     :integer
#  secondary_agent_id                    :integer
#  signing_date                          :date
#  status_value                          :string
#  type                                  :string           not null
#  updated_at                            :datetime         not null
#
# Indexes
#
#  index_projects_on_currency_id      (currency_id)
#  index_projects_on_division_id      (division_id)
#  index_projects_on_organization_id  (organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (currency_id => currencies.id)
#  fk_rails_...  (division_id => divisions.id)
#  fk_rails_...  (organization_id => organizations.id)
#  fk_rails_...  (primary_agent_id => people.id)
#  fk_rails_...  (representative_id => people.id)
#  fk_rails_...  (secondary_agent_id => people.id)
#

class BasicProject < Project
  attr_option_settable :status

  def start_date
    signing_date
  end

  def default_name
    I18n.t("common.untitled")
  end

  def display_name
    name.blank? ? default_name : name
  end

  def status
    status_label
  end

  def organization
    nil
  end
end
