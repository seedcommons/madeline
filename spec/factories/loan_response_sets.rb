# == Schema Information
#
# Table name: loan_response_sets
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
#  loan_response_sets_on_settable                   (custom_field_addable_type,custom_field_addable_id)
#  index_loan_response_sets_on_custom_field_set_id  (custom_field_set_id)
#

FactoryGirl.define do
  factory :loan_response_set do
    loan
    custom_field_set
    transient_division
  end
end
