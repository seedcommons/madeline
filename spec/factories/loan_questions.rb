# == Schema Information
#
# Table name: loan_questions
#
#  created_at            :datetime         not null
#  data_type             :string
#  has_embeddable_media  :boolean          default(FALSE), not null
#  id                    :integer          not null, primary key
#  internal_name         :string
#  loan_question_set_id  :integer
#  migration_position    :integer
#  override_associations :boolean          default(FALSE), not null
#  parent_id             :integer
#  position              :integer
#  required              :boolean          default(FALSE), not null
#  status                :string           default("active"), not null
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_loan_questions_on_loan_question_set_id  (loan_question_set_id)
#
# Foreign Keys
#
#  fk_rails_a32cf017b9  (loan_question_set_id => loan_question_sets.id)
#

FactoryGirl.define do
  factory :loan_question do
    loan_question_set
    internal_name Faker::Lorem.words(2).join('_').downcase
    data_type LoanQuestion::DATA_TYPES.sample
    position [1..10].sample
    parent nil
    transient_division

    after(:create) do |model|
      model.set_label(Faker::Lorem.words(2).join(' '))
    end
  end
end
