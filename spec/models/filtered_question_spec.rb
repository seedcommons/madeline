require 'rails_helper'

describe FilteredQuestion, type: :model do
  let(:d0) { create(:division, name: 'Root Division') }
  let(:d1) { create(:division, name: 'First Division') }
  let(:d11) { create(:division, name: 'Child - First Division') }
  let(:d2) { create(:division, name: 'Second Division') }
  let(:d21) { create(:division, name: 'Child - Second Division') }

  let(:q0) { create(:loan_question, division: d0) }
  let(:q1) { create(:loan_question, division: d1) }
  let(:q2) { create(:loan_question, division: d2) }


  # create division generations
  before do
    d0.add_child(d1)
    d0.add_child(d2)
    d1.add_child(d11)
    d2.add_child(d21)
  end

  it 'filters correctly' do
    expect(FilteredQuestion.new(q0, division: d0).visible?).to be_truthy
    expect(FilteredQuestion.new(q1, division: d1).visible?).to be_truthy
    expect(FilteredQuestion.new(q1, division: d11).visible?).to be_falsey
    expect(FilteredQuestion.new(q1, division: d2).visible?).to be_falsey
    expect(FilteredQuestion.new(q1, division: d21).visible?).to be_falsey
    expect(FilteredQuestion.new(q1, division: d0).visible?).to be_truthy
    expect(FilteredQuestion.new(q2, division: d1).visible?).to be_falsey
    expect(FilteredQuestion.new(q2, division: d0).visible?).to be_truthy
  end
end
