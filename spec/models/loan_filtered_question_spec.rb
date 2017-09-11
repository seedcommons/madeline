require 'rails_helper'

RSpec.describe LoanFilteredQuestion, type: :model do
  include_context "full question set and responses"

  describe '#parent' do
    subject(:parent) { LoanFilteredQuestion.new(q31, loan1).parent }

    it { should be_a LoanFilteredQuestion }

    it 'should have the right loan' do
      expect(parent.loan).to eq loan1
    end
  end

  describe '#children' do
    subject(:children) { LoanFilteredQuestion.new(q3, loan1).children }

    it 'should return the same class' do
      expect(children.first).to be_a LoanFilteredQuestion
    end

    it 'hides invisible questions' do

    end
  end

  describe '#required?' do
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
      expect(LoanFilteredQuestion.new(q381, loan1).required?).to be false
    end

    it 'not required on child when override false even when association is present' do
      expect(LoanFilteredQuestion.new(q4, loan1).required?).to be false
    end
  end
end
