# == Schema Information
#
# Table name: custom_field_sets
#
#  id            :integer          not null, primary key
#  division_id   :integer
#  internal_name :string
#  label         :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_custom_field_sets_on_division_id  (division_id)
#

FactoryGirl.define do
  factory :custom_field_set do
    division { Division.root }
    internal_name Faker::Lorem.words(2).join('_').downcase

    before(:create) do
      # explicitly ensure that the default language used by the translatable module exists
      Language.system_default
    end

    after(:create) do |model|
      model.set_label(Faker::Lorem.words(2).join(' '))
    end


    trait :loan_criteria do
      internal_name Loan::LOAN_CRITERIA_FIELD_SET_SYMBOL
      after(:create) do |model|
        model.set_label('Loan Criteria Questionnaire')
        create(:custom_field, custom_field_set: model, internal_name: 'summary', data_type: 'text')
        create(:custom_field, custom_field_set: model, internal_name: 'workers', data_type: 'number')
      end
    end

    trait :loan_post_analysis do
      internal_name Loan::POST_ANALYSIS_FIELD_SET_SYMBOL
      after(:create) do |model|
        model.set_label('Loan Post Analysis')
        create(:custom_field, custom_field_set: model, internal_name: 'new_worker_knowledge', data_type: 'text')
        create(:custom_field, custom_field_set: model, internal_name: 'total_loan_amount', data_type: 'number')
      end
    end

    trait :organization_fields do
      internal_name Organization.name
      after(:create) do |model|
        create(:custom_field, custom_field_set: model, internal_name: 'is_recovered', data_type: 'boolean')
      end
    end


  end

end


