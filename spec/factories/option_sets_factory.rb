FactoryBot.define do
  factory :option_set do
    division { root_division }
    model_type { "Loan" }
    model_attribute { "status" }
  end
end
