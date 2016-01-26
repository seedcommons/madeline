# == Schema Information
#
# Table name: custom_value_sets
#
#  id                         :integer          not null, primary key
#  custom_value_settable_id   :integer
#  custom_value_settable_type :string
#  custom_field_set_id        :integer
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#
# Indexes
#
#  custom_value_sets_on_settable                   (custom_value_settable_type,custom_value_settable_id)
#  index_custom_value_sets_on_custom_field_set_id  (custom_field_set_id)
#

FactoryGirl.define do
  factory :custom_model do
    association :custom_model_linkable, factory: :loan
    custom_field_set
  end

end
