require 'rails_helper'

describe LoanQuestionPolicy do
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

  subject { LoanQuestionPolicy.new(user, described_question) }

  context 'user in second level division' do
    let!(:user) { create(:user, :admin, division: d1) }

    context 'question in ancestor division' do
      let(:described_question) { q0 }

      permit_actions [:index, :show]
      forbid_actions [:edit, :update, :new, :create, :destroy]
    end

    context 'question in same level division' do
      let(:described_question) { q1 }

      permit_actions [:index, :show, :edit, :update, :new, :create, :destroy]
    end

    context 'question in descendant division' do
      let(:described_question) { q11 }

      permit_actions [:index, :show, :edit, :update, :new, :create, :destroy]
    end

    context 'question in unaffiliated division' do
      let(:described_question) { q2 }

      permit_actions [:index]
      forbid_actions [:show, :edit, :update, :new, :create, :destroy]
    end
  end
end
