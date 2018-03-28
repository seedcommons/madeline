require 'rails_helper'

describe LoanPolicy do
  it_should_behave_like 'base_policy', :loan
  it_should_behave_like 'division_owned_scope', :loan

  subject { LoanPolicy.new(user, Loan.where(conditions)) }
  let!(:division) { create(:division) }
  let!(:loan1) { create(:loan, division: division, public_level_value: 'featured') }
  let!(:loan2) { create(:loan, division: division, public_level_value: 'featured') }
  let!(:loan3) { create(:loan, division: division, public_level_value: 'hidden') }

  describe 'with user' do
    let!(:user) { create(:user, :admin, division: division) }
    before { user.accessible_division_ids }

    it 'returns the correct loans' do
      expect(loan_scope(user).resolve).to contain_exactly(loan1, loan2, loan3)
    end

    it 'allows the show action' do
      permit_action [:show]
    end
  end

  describe 'without user' do
    let!(:user) { nil }
    before { user.try(:accessible_division_ids) }

    it 'returns the correct loans' do
      expect(loan_scope(user).resolve).to contain_exactly(loan1, loan2)
    end

    it 'allows the show action' do
      permit_action [:show]
    end
  end

  def loan_scope(user, conditions = nil)
    LoanPolicy::Scope.new(user, Loan.where(conditions))
  end
end
