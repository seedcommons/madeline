# == Schema Information
#
# Table name: projects
#
#  actual_end_date                       :date
#  actual_first_interest_payment_date    :date
#  actual_first_payment_date             :date
#  actual_return                         :decimal(, )
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
#  projected_first_payment_date          :date
#  projected_return                      :decimal(, )
#  public_level_value                    :string           not null
#  rate                                  :decimal(, )
#  representative_id                     :integer
#  secondary_agent_id                    :integer
#  signing_date                          :date
#  status_value                          :string
#  txn_handling_mode                     :string           default("automatic"), not null
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

require 'rails_helper'

describe BasicProject, type: :model do
  include_context 'project'

  it_should_behave_like 'translatable', ['summary', 'details']
  it_should_behave_like 'option_settable', ['status']

  it 'has a valid factory' do
    expect(create(:basic_project)).to be_valid
  end

  context 'primary and secondary agents' do

    context 'create' do
      it 'raises error if agents are the same' do
        expect(p_1).not_to be_valid
        expect(p_1.errors[:primary_agent].join).to match(error)
      end

      it 'does not raise error for different agents' do
        expect(p_2).to be_valid
      end
    end
  end
end
