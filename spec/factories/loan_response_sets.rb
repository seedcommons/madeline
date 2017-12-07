# == Schema Information
#
# Table name: loan_response_sets
#
#  created_at  :datetime         not null
#  custom_data :json
#  id          :integer          not null, primary key
#  kind        :string
#  loan_id     :integer          not null
#  updated_at  :datetime         not null
#

FactoryGirl.define do
  factory :loan_response_set do
    loan
    kind 'criteria'
  end
end
