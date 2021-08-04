FactoryBot.define do
  factory :option do
    option_set
    position { 1 }
    value { 'active' }
    transient_division
  end

end
