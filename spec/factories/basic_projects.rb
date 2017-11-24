FactoryGirl.define do
  factory :basic_project do
    division { root_division }
    status_value 'MyString'
    primary_agent nil
    secondary_agent nil
  end
end
