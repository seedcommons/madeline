# == Schema Information
#
# Table name: loan_question_sets
#
#  created_at    :datetime         not null
#  division_id   :integer
#  id            :integer          not null, primary key
#  internal_name :string
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_loan_question_sets_on_division_id  (division_id)
#
# Foreign Keys
#
#  fk_rails_13da1a92b4  (division_id => divisions.id)
#

FactoryGirl.define do
  factory :loan_question_set do
    internal_name Faker::Lorem.words(2).join('_').downcase

    after(:create) do |model|
      model.set_label(Faker::Lorem.words(2).join(' '))
    end

    trait :generic_fields do
      after(:create) do |model|
        create(:loan_question, parent: model.root_group, loan_question_set: model,
          internal_name: 'a_string', data_type: 'string')
        create(:loan_question, parent: model.root_group, loan_question_set: model,
          internal_name: 'a_number', data_type: 'number')
        create(:loan_question, parent: model.root_group, loan_question_set: model,
          internal_name: 'a_boolean', data_type: 'boolean')
      end
    end

    trait :loan_criteria do
      internal_name 'loan_criteria'
      after(:create) do |model|
        model.set_label('Loan Criteria Questionnaire')
        create(:loan_question, parent: model.root_group, loan_question_set: model,
          internal_name: 'summary', data_type: 'text')
        create(:loan_question, parent: model.root_group, loan_question_set: model,
          internal_name: 'workers', data_type: 'number')
      end
    end

    trait :loan_post_analysis do
      internal_name 'loan_post_analysis'
      after(:create) do |model|
        model.set_label('Loan Post Analysis')
        create(:loan_question, parent: model.root_group, loan_question_set: model,
          internal_name: 'new_worker_knowledge', data_type: 'text')
        create(:loan_question, parent: model.root_group, loan_question_set: model,
          internal_name: 'total_loan_amount', data_type: 'number')
      end
    end
  end
end
