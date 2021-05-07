# frozen_string_literal: true

require 'rails_helper'

describe Accounting::ProblemLoanTransactionPolicy do
  let(:parent_division) { create(:division, :with_accounts, qb_read_only: false) }
  let(:division) { create(:division, :with_qb_dept, parent: parent_division) }
  let(:loan_trait) { :active }
  let(:loan_txn_mode) { Loan::TXN_MODE_AUTO }
  let(:loan) { create(:loan, loan_trait, division: division, txn_handling_mode: loan_txn_mode) }
  let(:txn) { Accounting::Transaction.new(project: loan) }
  let(:described_plt) { Accounting::ProblemLoanTransaction.new(project_id: loan.id, accounting_transaction_id: txn.id) }
  subject(:policy) { described_class.new(user, described_plt) }

  context 'with non-admin' do
    let(:user) { create(:user) }
    forbid_all
  end

  context 'with admin of unrelated division' do
    let(:user) { create(:user, :admin, division: create(:division)) }
    forbid_all
  end

  context 'with admin of same non-root division' do
    let(:user) { create(:user, :admin, division: division) }
    forbid_all
  end

  context 'with root admin' do
    let(:user) { create_admin(root_division) }
    forbid_all_but_read
  end
end
