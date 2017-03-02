# == Schema Information
#
# Table name: users
#
#  created_at             :datetime         not null
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :inet
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  id                     :integer          not null, primary key
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :inet
#  notify_on_new_logs     :boolean          default(TRUE)
#  profile_id             :integer
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_profile_id            (profile_id)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_a8794354f0  (profile_id => people.id)
#

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
    profile { create(:person) }
    transient_division

    trait :member do
      transient do
        division { create(:division) }
      end

      after(:create) do |user, evaluator|
        user.add_role :member, evaluator.division if evaluator.division.present?
      end
    end

    trait :admin do
      profile { create(:person, :with_admin_access, :with_password) }

      after(:create) do |user, evaluator|
        user.add_role :admin, evaluator.division if evaluator.division.present?
      end
    end
  end
end
