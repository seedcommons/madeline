# == Schema Information
#
# Table name: option_sets
#
#  id              :integer          not null, primary key
#  division_id     :integer          not null
#  model_type      :string
#  model_attribute :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_option_sets_on_division_id  (division_id)
#

FactoryGirl.define do
  factory :option_set do
    division
    model_type "Loan"
    model_attribute "status"
  end

end
