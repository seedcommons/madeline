# == Schema Information
#
# Table name: custom_value_sets
#
#  id                         :integer          not null, primary key
#  custom_field_addable_id   :integer
#  custom_field_addable_type :string
#  custom_field_set_id        :integer
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#
# Indexes
#
#  custom_value_sets_on_settable                   (custom_field_addable_type,custom_field_addable_id)
#  index_custom_value_sets_on_custom_field_set_id  (custom_field_set_id)
#

FactoryGirl.define do
  factory :custom_value_set do
    association :custom_value_set_linkable, factory: :loan
    custom_field_set
    transient_division
  end
end
