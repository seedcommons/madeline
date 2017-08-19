require 'rails_helper'

RSpec.describe LoanFilteredQuestion, type: :model do
  describe 'required?' do
    let!(:loan_type_set) { create(:option_set, division: root_division, model_type: ::Loan.name, model_attribute: 'loan_type') }
    let!(:lt1) { create(:option, option_set: loan_type_set, value: 'lt1', label_translations: {en: 'Loan Type One'}) }
    let!(:lt2) { create(:option, option_set: loan_type_set, value: 'lt2', label_translations: {en: 'Loan Type Two'}) }

    let!(:loan1) { create(:loan, loan_type_value: lt1.value)}
    let!(:loan2) { create(:loan, loan_type_value: lt2.value)}

    let!(:set) { create(:loan_question_set) }
    let!(:lqroot) { create_question(set: set, name: "lqroot", type: "group") }
    let!(:q1) { create_question(set: set, parent: lqroot, name: "q1", type: "text") }

    let!(:q2) { create_question(set: set, parent: lqroot, name: "q4", type: "text",
      override_associations: true, loan_types: [lt1,lt2]) }

    let!(:q3) { create_question(set: set, parent: lqroot, name: "q3", type: "group",
      override_associations: true, loan_types: [lt1]) }
    let!(:q31) { create_question(set: set, parent: q3, name: "q31", type: "string") }
    let!(:q33) { create_question(set: set, parent: q3, name: "q33", type: "group") }
    let!(:q331) { create_question(set: set, parent: q33, name: "q331", type: "boolean") }
    let!(:q332) { create_question(set: set, parent: q33, name: "q332", type: "number",
      override_associations: true, loan_types: [lt2]) }
    let!(:q333) { create_question(set: set, parent: q33, name: "q333", type: "text",
      override_associations: true) }

    let!(:q4) { create_question(set: set, parent: q1, name: "q4", type: "text",
      loan_types: [lt1,lt2]) }

    it 'not required by default' do
      expect(LoanFilteredQuestion.new(q1, loan1).required?).to be false
    end

    it 'required when override true and assocation present' do
      expect(LoanFilteredQuestion.new(q3, loan1).required?).to be true
    end

    it 'not required when override true and assocation not present' do
      expect(LoanFilteredQuestion.new(q3, loan2).required?).to be false
    end

    it 'required when inherited and parent association present' do
      expect(LoanFilteredQuestion.new(q31, loan1).required?).to be true
    end

    it 'not required when inherited and parent association not present' do
      expect(LoanFilteredQuestion.new(q31, loan2).required?).to be false
    end

    it 'not required when override true for child and not present at child level' do
      expect(LoanFilteredQuestion.new(q332, loan1).required?).to be false
    end

    it 'required when override true for child and present at child level' do
      expect(LoanFilteredQuestion.new(q332, loan2).required?).to be true
    end

    it 'required when override true and association present for both types' do
      expect(LoanFilteredQuestion.new(q2, loan2).required?).to be true
    end

    it 'not required when override true for child and no associations present' do
      expect(LoanFilteredQuestion.new(q333, loan1).required?).to be false
    end

    it 'not required on child when override false even when association is present' do
      expect(LoanFilteredQuestion.new(q4, loan1).required?).to be false
    end
  end
end
