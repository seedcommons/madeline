# == Schema Information
#
# Table name: custom_fields
#
#  id                  :integer          not null, primary key
#  custom_field_set_id :integer
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
#  index_custom_fields_on_custom_field_set_id  (custom_field_set_id)
#

FactoryGirl.define do
  factory :custom_field do
    custom_field_set
    internal_name Faker::Lorem.words(2).join('_').downcase
    data_type CustomField::DATA_TYPES.sample
    position [1..10].sample
    parent nil

    after(:create) do |model|
      model.set_label(Faker::Lorem.words(2).join(' '))
    end

    transient do
      division { custom_field_set.division }
    end

    after(:create) do |custom_field, evaluator|
      custom_field.custom_field_set.division = evaluator.division if evaluator.division.present?
    end
  end

end
