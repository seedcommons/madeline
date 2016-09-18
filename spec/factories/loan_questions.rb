# == Schema Information
#
# Table name: loan_questions
#
#  id                  :integer          not null, primary key
#  loan_question_set_id :integer
#  internal_name       :string
#  label               :string
#  data_type           :string
#  position            :integer
#  parent_id           :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_loan_questions_on_loan_question_set_id  (loan_question_set_id)
#

FactoryGirl.define do
  factory :loan_question do
    loan_question_set
    internal_name Faker::Lorem.words(2).join('_').downcase
    data_type LoanQuestion::DATA_TYPES.sample
    position [1..10].sample
    parent nil
    transient_division

    after(:create) do |model|
      model.set_label(Faker::Lorem.words(2).join(' '))
    end
  end
end
