require 'rails_helper'

describe FilteredQuestion, type: :model do
  let!(:d0) { create(:division, name: 'Root Division') }
    let!(:d1) { create(:division, name: 'First Division', parent: d0) }
      let!(:d11) { create(:division, name: 'Child - First Division', parent: d1) }
    let!(:d2) { create(:division, name: 'Second Division', parent: d0) }
      let!(:d21) { create(:division, name: 'Child - Second Division', parent: d2) }

  let!(:q0) { create(:loan_question, division: d0) }
    let!(:q1) { create(:loan_question, division: d1) }
      let!(:q11) { create(:loan_question, division: d11) }
    let!(:q2) { create(:loan_question, division: d2) }
    let!(:q2_a) { create(:loan_question, parent: q2, division: d2) }
    let!(:q2_b) { create(:loan_question, parent: q2, division: d21) }
      let!(:q21) { create(:loan_question, division: d21) }

  describe '#visible?' do
    shared_examples_for 'full visibility' do
      it 'shows only questions belonging to the selected division and its ancestors' do
        # Root division selected
        expect(filtered_question(q0, d0)).to be_visible
        expect(filtered_question(q1, d0)).not_to be_visible
        expect(filtered_question(q11, d0)).not_to be_visible
        expect(filtered_question(q2, d0)).not_to be_visible
        expect(filtered_question(q2_a, d0)).not_to be_visible
        expect(filtered_question(q2_b, d0)).not_to be_visible
        expect(filtered_question(q21, d0)).not_to be_visible

        # Middle-generation division selected
        expect(filtered_question(q0, d1)).to be_visible
        expect(filtered_question(q1, d1)).to be_visible
        expect(filtered_question(q11, d1)).not_to be_visible
        expect(filtered_question(q2, d1)).not_to be_visible
        expect(filtered_question(q2_a, d1)).not_to be_visible
        expect(filtered_question(q2_b, d1)).not_to be_visible
        expect(filtered_question(q21, d1)).not_to be_visible

        # Leaf division selected
        expect(filtered_question(q0, d11)).to be_visible
        expect(filtered_question(q1, d11)).to be_visible
        expect(filtered_question(q11, d11)).to be_visible
        expect(filtered_question(q2, d11)).not_to be_visible
        expect(filtered_question(q2_a, d11)).not_to be_visible
        expect(filtered_question(q2_b, d11)).not_to be_visible
        expect(filtered_question(q21, d11)).not_to be_visible

        # Middle-generation division selected
        expect(filtered_question(q0, d2)).to be_visible
        expect(filtered_question(q1, d2)).not_to be_visible
        expect(filtered_question(q11, d2)).not_to be_visible
        expect(filtered_question(q2, d2)).to be_visible
        expect(filtered_question(q2_a, d2)).to be_visible
        expect(filtered_question(q2_b, d2)).not_to be_visible
        expect(filtered_question(q21, d2)).not_to be_visible

        # Leaf division selected
        expect(filtered_question(q0, d21)).to be_visible
        expect(filtered_question(q1, d21)).not_to be_visible
        expect(filtered_question(q11, d21)).not_to be_visible
        expect(filtered_question(q2, d21)).to be_visible
        expect(filtered_question(q2_a, d21)).to be_visible
        expect(filtered_question(q2_b, d21)).to be_visible
        expect(filtered_question(q21, d21)).to be_visible
      end
    end

    context 'with top division user' do
      let(:user) { create(:user, :admin, division: d0) }

      it_behaves_like 'full visibility'
    end

    context 'with system user' do
      let(:user) { :system }

      it_behaves_like 'full visibility'
    end

    context 'with user in lower division' do
      let(:user) { create(:user, :admin, division: d1) }

      it 'should still be able to see questions from ancestor division' do
        # This is usually not permitted for most objects. Loan questions are different.
        expect(filtered_question(q0, d0)).to be_visible
      end

      it 'should not be able to see questions in divisions outside own acestors and descendants' do
        expect(filtered_question(q2, d2)).not_to be_visible
      end
    end
  end

  describe '#children' do
    let(:user) { create(:user, :admin, division: d0) }

    it 'should return only visible children' do
      q2.reload
      expect(filtered_question(q2, d21).children.map(&:object)).to contain_exactly(q2_a, q2_b)
      expect(filtered_question(q2, d2).children.map(&:object)).to contain_exactly(q2_a)
    end
  end

  def filtered_question(q, d)
    FilteredQuestion.new(q, division: d, user: user)
  end
end
