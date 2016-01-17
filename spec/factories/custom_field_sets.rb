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
      # todo: confirm which approach is preferred

      # note, by using the translation factory, we'll implicitly ensure that a language exists,
      # but it's not guaranteed to match what is expected by the default translatable resolve
      # create(:translation, translatable: model, translatable_attribute: 'label', text: Faker::Lorem.words(2).join(' '))

      Language.system_default  # explicitly ensure that the default language used by the translatable module exists
      model.set_label(Faker::Lorem.words(2).join(' '))

    end
  end

end


