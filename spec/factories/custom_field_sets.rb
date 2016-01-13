# == Schema Information
#
# Table name: custom_field_sets
#
#  id            :integer          not null, primary key
#  division_id   :integer
#  internal_name :string
#  label         :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_custom_field_sets_on_division_id  (division_id)
#

FactoryGirl.define do
  factory :custom_field_set do
    division
    internal_name Faker::Lorem.words(2).join('_').downcase

    after(:create) do |model|
      model.set_label(Faker::Lorem.words(2).join(' '))
    end

  end

end


