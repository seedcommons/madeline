# == Schema Information
#
# Table name: option_sets
#
#  created_at      :datetime         not null
#  division_id     :integer          not null
#  id              :integer          not null, primary key
#  model_attribute :string
#  model_type      :string
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_option_sets_on_division_id  (division_id)
#
# Foreign Keys
#
#  fk_rails_1565c19047  (division_id => divisions.id)
#

FactoryGirl.define do
  factory :option_set do
    division { root_division }
    model_type "Loan"
    model_attribute "status"
  end
end
