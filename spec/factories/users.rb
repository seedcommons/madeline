FactoryGirl.define do
  factory :user do
    created_at { Faker::Date.between(Date.civil(2004, 01, 01), Date.today) }
    current_sign_in_at { Faker::Date.between(created_at, Date.today) }
    current_sign_in_ip { Faker::Internet.ip_v4_address }
    email { Faker::Internet.email }
    password { Faker::Internet.password }
    password_confirmation { password }
    last_sign_in_at { Faker::Date.between(created_at, current_sign_in_at) }
    last_sign_in_ip { Faker::Internet.ip_v4_address }
    remember_created_at { Faker::Date.between(created_at, Date.today) }
    reset_password_sent_at { Faker::Date.between(created_at, Date.today) }
    reset_password_token { Faker::Internet.password }
    sign_in_count { rand(1..25) }
    updated_at { Faker::Date.between(created_at, current_sign_in_at) }
  end
end
