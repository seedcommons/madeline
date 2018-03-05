# == Schema Information
#
# Table name: questions
#
#  created_at            :datetime         not null
#  data_type             :string           not null
#  division_id           :integer          not null
#  has_embeddable_media  :boolean          default(FALSE), not null
#  id                    :integer          not null, primary key
#  internal_name         :string
#  loan_question_set_id  :integer
#  migration_position    :integer
#  number                :integer
#  override_associations :boolean          default(FALSE), not null
#  parent_id             :integer
#  position              :integer
#  required              :boolean          default(FALSE), not null
#  status                :string           default("active"), not null
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_questions_on_loan_question_set_id  (loan_question_set_id)
#
# Foreign Keys
#
#  fk_rails_...  (loan_question_set_id => loan_question_sets.id)
#

FactoryBot.define do
  factory :question do
    division { root_division }
    loan_question_set
    internal_name Faker::Lorem.words(2).join('_').downcase
    data_type Question::DATA_TYPES.sample
    position [1..10].sample
    status 'active'
    parent nil

    after(:create) do |model|
      model.set_label(Faker::Lorem.words(2).join(' '))
    end
  end
end
