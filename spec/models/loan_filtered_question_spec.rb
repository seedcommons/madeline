require "rails_helper"

RSpec.describe LoanFilteredQuestion, type: :model do
  include_context "full question set and responses"

  let(:lfq_root_1) { LoanFilteredQuestion.new(qset.root_group_preloaded, loan: rset_1.loan, response_set: rset_1) }
  let(:lookup_table_1) { lookup_table_for(lfq_root_1) }
  let(:lfq_root_2) { LoanFilteredQuestion.new(qset.root_group_preloaded, loan: rset_2.loan, response_set: rset_2) }
  let(:lookup_table_2) { lookup_table_for(lfq_root_2) }

  # let!(:lfq_root) { LoanFilteredQuestion.new(qset.root_group_preloaded, loan: rset_1.loan, response_set: rset_1) }
  # let!(:lookup_table) { lookup_table_for(lfq_root) }

  describe '#visible_children' do
    let!(:visible_children) { lookup_table_1[q3.id].visible_children }

    it 'returns decorated objects' do
      expect(visible_children.first).to be_a LoanFilteredQuestion
    end

    it 'returns only visible questions in the correct order' do
      expect(visible_children.map(&:question)).to eq [q31, q32, q33, q35, q34, q38, q39]
    end
  end

  describe '#required?' do
    it 'not required by default' do
      expect(lookup_table_1[q1.id]).not_to be_required
    end

    it 'required when override true and assocation present' do
      expect(lookup_table_1[q3.id]).to be_required
    end

    it 'not required when override true and assocation not present' do
      #TODO figure out how to do with a different loan waaaahhhhhh
      expect(lookup_table_2[q3.id]).not_to be_required
    end

    it 'required when inherited and parent association present' do
      puts q31.root?
      puts q31.parent
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
