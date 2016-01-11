# == Schema Information
#
# Table name: notes
#
#  id           :integer          not null, primary key
#  notable_id   :integer
#  notable_type :string
#  author_id    :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_notes_on_author_id                    (author_id)
#  index_notes_on_notable_type_and_notable_id  (notable_type,notable_id)
#

FactoryGirl.define do
  factory :note do
    association :notable, factory: :organization
    association :author, factory: :person

    # for now parent must be saved before assigning the text
    after(:create) do |note|
      note.set_text(Faker::Lorem.sentence)
    end
  end
end
