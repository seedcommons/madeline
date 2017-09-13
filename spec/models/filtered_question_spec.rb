require 'rails_helper'

describe FilteredQuestion, type: :model do
  let(:d0) { create(:division, name: 'Root Division') }
    let(:d1) { create(:division, name: 'First Division', parent: d0) }
      let(:d11) { create(:division, name: 'Child - First Division', parent: d1) }
    let(:d2) { create(:division, name: 'Second Division', parent: d0) }
      let(:d21) { create(:division, name: 'Child - Second Division', parent: d2) }

  let(:q0) { create(:loan_question, division: d0) }
    let(:q1) { create(:loan_question, division: d1) }
      let(:q11) { create(:loan_question, division: d11) }
    let(:q2) { create(:loan_question, division: d2) }
      let(:q21) { create(:loan_question, division: d21) }

  it 'shows only questions belonging to the selected division and its ancestors' do
    # Root division selected
    expect(filtered_question(q0, d0).visible?).to be_truthy
    expect(filtered_question(q1, d0).visible?).to be_falsey
    expect(filtered_question(q11, d0).visible?).to be_falsey
    expect(filtered_question(q2, d0).visible?).to be_falsey
    expect(filtered_question(q21, d0).visible?).to be_falsey

    # Middle-generation division selected
    expect(filtered_question(q0, d1).visible?).to be_truthy
    expect(filtered_question(q1, d1).visible?).to be_truthy
    expect(filtered_question(q11, d1).visible?).to be_falsey
    expect(filtered_question(q2, d1).visible?).to be_falsey
    expect(filtered_question(q21, d1).visible?).to be_falsey

    # Leaf division selected
    expect(filtered_question(q0, d11).visible?).to be_truthy
    expect(filtered_question(q1, d11).visible?).to be_truthy
    expect(filtered_question(q11, d11).visible?).to be_truthy
    expect(filtered_question(q2, d11).visible?).to be_falsey
    expect(filtered_question(q21, d11).visible?).to be_falsey

    # "All divisions" selected - show all questions
    expect(filtered_question(q0, nil).visible?).to be_truthy
    expect(filtered_question(q1, nil).visible?).to be_truthy
    expect(filtered_question(q11, nil).visible?).to be_truthy
    expect(filtered_question(q2, nil).visible?).to be_truthy
    expect(filtered_question(q21, nil).visible?).to be_truthy
  end

  def filtered_question(q, d)
    FilteredQuestion.new(q, division: d)
  end
end
