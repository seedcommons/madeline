# frozen_string_literal: true

require 'rails_helper'

describe Accounting::TransactionPolicy do
  let(:qb_division) { create(:division, :with_accounts, qb_read_only: false) }
  let(:division) { create(:division, :with_qb_dept, parent: qb_division) }
  let(:loan_trait) { :active }
  let(:loan_txn_mode) { Loan::TXN_MODE_AUTO }
  let(:loan) { create(:loan, loan_trait, division: division, txn_handling_mode: loan_txn_mode) }
  let(:described_transaction) { Accounting::Transaction.new(project: loan) }
  subject(:policy) { described_class.new(user, described_transaction) }

  shared_examples_for 'returns no reasons even if issues other than user role' do
    it { expect(policy.read_only_reasons).to be_empty }

    context 'with other issues present' do
      let(:loan_trait) { :completed }
      it { expect(policy.read_only_reasons).to be_empty }
    end
  end

  context 'with non-admin' do
    let(:user) { create(:user) }
    forbid_all
    it_behaves_like 'returns no reasons even if issues other than user role'
  end

  context 'with admin of wrong division' do
    let(:user) { create(:user, :admin, division: create(:division)) }
    forbid_all
    it_behaves_like 'returns no reasons even if issues other than user role'
  end

  shared_examples_for 'admin or machine user' do
    context 'with all other things in order' do
      permit_actions [:show, :create, :update]
      forbid_actions [:index, :destroy]
    end

    context 'with accounts not selected' do
      let(:qb_division) { create(:division, qb_read_only: false) }
      forbid_all_but_show
      it { expect(policy.read_only_reasons).to contain_exactly(:accounts_not_selected) }
    end

    context 'with division transactions read only' do
      let(:qb_division) { create(:division, :with_accounts, qb_read_only: true) }
      forbid_all_but_show
      it { expect(policy.read_only_reasons).to contain_exactly(:division_transactions_read_only) }
    end

    context 'with department not set' do
      let(:division) { create(:division, parent: qb_division) }
      forbid_all_but_show
      it { expect(policy.read_only_reasons).to contain_exactly(:department_not_set) }
    end

    context 'with loan inactive' do
      let(:loan_trait) { :completed }
      forbid_all_but_show
      it { expect(policy.read_only_reasons).to contain_exactly(:loan_not_active) }
    end

    context 'with loan transactions read only' do
      let(:loan_txn_mode) { Loan::TXN_MODE_READ_ONLY }
      forbid_all_but_show
      it { expect(policy.read_only_reasons).to contain_exactly(:loan_transactions_read_only) }
    end

    context 'with multiple issues' do
      let(:loan_trait) { :completed }
      let(:loan_txn_mode) { Loan::TXN_MODE_READ_ONLY }

      forbid_all_but_show

      it do
        expect(policy.read_only_reasons).to contain_exactly(:loan_not_active, :loan_transactions_read_only)
      end
    end
  end

  context 'with admin' do
    let(:user) { create(:user, :admin, division: division) }
    it_behaves_like 'admin or machine user'
  end

  context 'with :machine user' do
    let(:user) { :machine }
    it_behaves_like 'admin or machine user'
  end
end
