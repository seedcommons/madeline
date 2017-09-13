require 'rails_helper'

RSpec.describe LoanFilteredQuestion, type: :model do
  include_context "full question set and responses"

  describe '#parent' do
    let(:parent) { described_class.new(q31, loan: loan1).parent }

    it 'returns a decorated object' do
      expect(parent).to be_a LoanFilteredQuestion
    end

    it 'should have the right loan' do
      expect(parent.loan).to eq loan1
    end
  end

  describe '#children' do
    let(:children) { described_class.new(q3.reload, loan: loan1).children }

    it 'returns decorated objects' do
      expect(children.first).to be_a LoanFilteredQuestion
    end

    # This also serves as an indirect test for #visible? and #answered?
    it 'returns only visible questions in the correct order' do
      expect(children.map(&:object)).to eq [q35, q31, q32, q33, q34, q38, q39]
    end
  end

  describe '#required?' do
    it 'not required by default' do
      expect(described_class.new(q1, loan: loan1)).not_to be_required
    end

    it 'required when override true and assocation present' do
      expect(described_class.new(q3, loan: loan1)).to be_required
    end

    it 'not required when override true and assocation not present' do
      expect(described_class.new(q3, loan: loan2)).not_to be_required
    end

    it 'required when inherited and parent association present' do
      expect(described_class.new(q31, loan: loan1)).to be_required
    end

    it 'not required when inherited and parent association not present' do
      expect(described_class.new(q31, loan: loan2)).not_to be_required
    end

    it 'not required when override true for child and not present at child level' do
      expect(described_class.new(q332, loan: loan1)).not_to be_required
    end

    it 'required when override true for child and present at child level' do
      expect(described_class.new(q332, loan: loan2)).to be_required
    end

    it 'required when override true and association present for both types' do
      expect(described_class.new(q2, loan: loan2)).to be_required
    end

    it 'not required when override true for child and no associations present' do
      expect(described_class.new(q381, loan: loan1)).not_to be_required
    end

    it 'not required on child when override false even when association is present' do
      expect(described_class.new(q4, loan: loan1)).not_to be_required
    end
  end
end
