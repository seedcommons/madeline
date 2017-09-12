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

  it 'filters correctly' do
    expect(FilteredQuestion.new(q0, division: d0).visible?).to be_truthy
    expect(FilteredQuestion.new(q1, division: d1).visible?).to be_truthy
    expect(FilteredQuestion.new(q1, division: d11).visible?).to be_falsey
    expect(FilteredQuestion.new(q1, division: d2).visible?).to be_falsey
    expect(FilteredQuestion.new(q1, division: d21).visible?).to be_falsey
    expect(FilteredQuestion.new(q1, division: d0).visible?).to be_truthy
    expect(FilteredQuestion.new(q11, division: d21).visible?).to be_falsey
    expect(FilteredQuestion.new(q11, division: d1).visible?).to be_truthy
    expect(FilteredQuestion.new(q11, division: d0).visible?).to be_truthy
    expect(FilteredQuestion.new(q11, division: d2).visible?).to be_falsey
    expect(FilteredQuestion.new(q2, division: d1).visible?).to be_falsey
    expect(FilteredQuestion.new(q2, division: d0).visible?).to be_truthy
  end
end
