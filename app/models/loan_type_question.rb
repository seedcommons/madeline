# == Schema Information
#
# Table name: loan_type_questions
#
#  created_at   :datetime         not null
#  division_id  :integer
#  id           :integer          not null, primary key
#  loan_type_id :integer
#  question_id  :integer
#  required     :boolean          default(FALSE), not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_loan_type_questions_on_division_id   (division_id)
#  index_loan_type_questions_on_loan_type_id  (loan_type_id)
#  index_loan_type_questions_on_question_id   (question_id)
#
# Foreign Keys
#
#  fk_rails_15b94dd4b0  (loan_type_id => options.id)
#  fk_rails_501c24a2e4  (division_id => divisions.id)
#  fk_rails_75e6d6743d  (question_id => custom_fields.id)
#

# Relation data between loan types ('Option's owned by the 'loan_type' OptionSet) and
# questions ('CustomField's owned by 'loan_criteria' or 'loan_post_analysis' 'CustomFieldSet's).
# Indicates which questions should be required or hidden per loan type and division/sub-division.

class LoanTypeQuestion < ActiveRecord::Base

  # Resolves all relation records for given leaf division and loan type, merging in records
  # from parent divisions which are not overridden.
  # Note, this list includes matches from all question sets (i.e. criteria and post_analysis).
  def self.resolve(division, loan_type)
    result = []
    division.ancestors.reverse.each do |d|
      items = where(division: d, loan_type: loan_type)
      question_ids = items.map(&:question_id)
      # Remove overridden parent division records
      result.reject! { |item| question_ids.include?(item.question_id) }
      result += items
    end
    result
  end

end
