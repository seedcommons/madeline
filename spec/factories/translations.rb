FactoryGirl.define do
  factory :translation do
    with_language_id
    translated_content { Faker::Lorem.sentence }
    remote_column_name 'Description'
    remote_table 'Loans'
    remote_id { create(:loan).id }
  end
end
