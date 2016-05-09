FactoryGirl.define do
  factory :embeddable_media, :class => 'EmbeddableMedia' do
    url Faker::Internet.url
    original_url Faker::Internet.url
    height [1..600].sample
    width [1..600].sample
  end
end
