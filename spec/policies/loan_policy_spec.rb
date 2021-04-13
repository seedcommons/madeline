require 'rails_helper'

describe LoanPolicy do
  it_should_behave_like 'base_policy', :loan
  it_should_behave_like 'division_owned_scope', :loan

  subject { LoanPolicy.new(user, Loan.where(conditions)) }
  let!(:public_division) { create(:division) }
  let!(:featured_active_loan) { create(:loan, :active, division: public_division, public_level_value: 'featured') }
  let!(:featured_completed_loan) { create(:loan, :active, division: public_division, public_level_value: 'featured') }
  let!(:featured_other_loan) { create(:loan, status: "prospective", division: public_division, public_level_value: 'featured') }
  let!(:hidden_active_loan) { create(:loan, :active, division: public_division, public_level_value: 'hidden') }
  let!(:hidden_division) { create(:division, public: false, parent: public_division) }
  let!(:non_hidden_loan_on_hidden_division) {create(:loan, :active, division: hidden_division, public_level_value: 'featured') }

  describe 'with user, as in madeline usage' do
    let!(:user) { create(:user, :admin, division: public_division) }

    it 'returns the correct loans' do
      expect(loan_scope(user).resolve).to contain_exactly(featured_active_loan, featured_completed_loan, hidden_active_loan)
    end

    it 'allows the show action' do
      permit_action [:show]
    end
  end

  describe 'without user, as in public usage' do
    let!(:user) { nil }

    it 'returns the correct loans' do
      expect(loan_scope(user).resolve).to contain_exactly(featured_active_loan, featured_completed_loan)
    end

    it 'allows the show action' do
      permit_action [:show]
    end
  end

  def loan_scope(user, conditions = nil)
    LoanPolicy::Scope.new(user, Loan.where(conditions))
  end
end
