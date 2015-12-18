FactoryGirl.define do
  factory :media do
    context_id { create(:cooperative).id }
    context_table 'Cooperative'
    date { Faker::Date.between(Date.civil(2004, 01, 01), Date.today) }
    description { Faker::Lorem.sentence }
    media_path { Faker::Avatar.image("#{context_table} #{context_id} #{priority}".parameterize) }
    member_id 1
    old_caption { Faker::Lorem.sentence }
    priority { [nil, 0, rand(1..30)] }

    after(:build) do |media|
      # strip query string from generated URLs because they aren't recognized by type matcher regex
      media.media_path = media.media_path.split('?').first
    end
  end
end
