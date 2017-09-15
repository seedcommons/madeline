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

      # "All divisions" selected - show all questions
      expect(filtered_question(q0, nil)).to be_visible
      expect(filtered_question(q1, nil)).to be_visible
      expect(filtered_question(q11, nil)).to be_visible
      expect(filtered_question(q2, nil)).to be_visible
      expect(filtered_question(q2_a, nil)).to be_visible
      expect(filtered_question(q2_b, nil)).to be_visible
      expect(filtered_question(q21, nil)).to be_visible
    end
  end

  describe '#children' do
    it 'should return only visible children' do
      q2.reload
      expect(filtered_question(q2, nil).children.map(&:object)).to contain_exactly(q2_a, q2_b)
      expect(filtered_question(q2, d2).children.map(&:object)).to contain_exactly(q2_a)
    end
  end

  def filtered_question(q, d)
    FilteredQuestion.new(q, division: d)
  end
end
