# Note, functional testing performed within custom_field_spec
FactoryGirl.define do
  factory :custom_field_requirement do
    custom_field
    association :loan_type, factory: :option
  end
end
