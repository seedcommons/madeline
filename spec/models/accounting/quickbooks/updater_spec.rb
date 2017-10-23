require 'rails_helper'

RSpec.describe Accounting::Quickbooks::Updater, type: :model do
  let(:connection) { instance_double(Accounting::Quickbooks::Connection, last_updated_at: last_updated_at) }
  let(:generic_service) { instance_double(Quickbooks::Service::ChangeDataCapture, since: double(all_types: [])) }
  let(:qb_id) { 34 }
  let(:division) { create(:division, :with_accounts) }
  let(:loan) { create(:loan, division: division) }
  let(:journal_entry) { instance_double(Quickbooks::Model::JournalEntry, id: qb_id, as_json: quickbooks_data) }
  let(:quickbooks_data) do
    { 'line_items' =>
     [{ 'id' => '0',
        'description' => 'Nate desc',
        'amount' => '15.09',
        'detail_type' => 'JournalEntryLineDetail',
        'journal_entry_line_detail' => {
          'posting_type' => 'Debit',
          'entity' => {
            'type' => 'Customer',
            'entity_ref' => { 'value' => '1', 'name' => "Amy's Bird Sanctuary", 'type' => nil } },
          'account_ref' => { 'value' => '84', 'name' => 'Accounts Receivable (A/R)', 'type' => nil },
          'class_ref' => { 'value' => '5000000000000026437', 'name' => loan.id, 'type' => nil },
          'department_ref' => nil } },
      { 'id' => '1',
        'description' => 'Nath desc',
        'amount' => '12.37',
        'detail_type' => 'JournalEntryLineDetail',
        'journal_entry_line_detail' => {
          'posting_type' => 'Credit',
          'entity' => {
            'type' => 'Customer',
            'entity_ref' => { 'value' => '1', 'name' => "Amy's Bird Sanctuary", 'type' => nil } },
          'account_ref' => { 'value' => '35', 'name' => division.principal_account.name, 'type' => nil },
          'class_ref' => { 'value' => '5000000000000026437', 'name' => loan.id, 'type' => nil },
          'department_ref' => nil } },
       { 'id' => '2',
         'description' => 'Jay desc',
         'amount' => '2.72',
         'detail_type' => 'JournalEntryLineDetail',
         'journal_entry_line_detail' => {
           'posting_type' => 'Credit',
           'entity' => {
             'type' => 'Customer',
             'entity_ref' => { 'value' => '1', 'name' => "Amy's Bird Sanctuary", 'type' => nil } },
           'account_ref' => { 'value' => '35', 'name' => division.interest_receivable_account.name, 'type' => nil },
           'class_ref' => { 'value' => '5000000000000026437', 'name' => loan.id, 'type' => nil },
           'department_ref' => nil } }],
      'id' => '167',
      'sync_token' => 0,
      'meta_data' => {
        'create_time' => '2017-04-18T10:14:30.000-07:00',
        'last_updated_time' => '2017-04-18T10:14:30.000-07:00' },
      'txn_date' => '2017-04-18',
      'total' => '19.99',
      'private_note' => 'Nate now testing' }
  end
  let(:txn) { create(:accounting_transaction, quickbooks_data: quickbooks_data) }
  let!(:line_items) do
    txn.line_items = [create(:line_item,
        qb_line_id: 0,
        description: 'Nate desc',
        amount: '15.09',
        account: create(:account, name: 'Accounts Receivable (A/R)'),
        posting_type: 'Debit'),
      create(:line_item,
        qb_line_id: 1,
        description: 'Nath desc',
        amount: '12.37',
        account: division.principal_account,
        posting_type: 'Credit'),
      create(:line_item,
        qb_line_id: 2,
        description: 'Jay desc',
        amount: '2.72',
        account: division.interest_receivable_account,
        posting_type: 'Credit')]
  end


  before do
    allow(subject).to receive(:service).and_return(generic_service)
    allow(connection).to receive(:update_attribute).with(:last_updated_at, anything)
  end

  subject { described_class.new(connection, quickbooks_data) }

  context 'a line item is added from QB' do
    let(:last_updated_at) { nil }

    before do
      quickbooks_data['line_items'] << {
        'id' => '3',
        'description' => 'Jazzy desc',
        'amount' => '1.0',
        'detail_type' => 'JournalEntryLineDetail',
        'journal_entry_line_detail' => {
          'posting_type' => 'Debit',
          'entity' => {
            'type' => 'Customer',
            'entity_ref' => { 'value' => '1', 'name' => "Amy's Bird Sanctuary", 'type' => nil } },
          'account_ref' => { 'value' => '84', 'name' => division.interest_receivable_account.name, 'type' => nil },
          'class_ref' => { 'value' => '5000000000000026437', 'name' => loan.id, 'type' => nil },
          'department_ref' => nil } }
      txn.update(quickbooks_data: quickbooks_data)
      subject.extract_qb_data(txn)
    end

    it 'updates correctly in Madeline', clean_with_truncation: true do
      expect(Accounting::LineItem.count).to eq(4)
      expect(txn.reload.line_items.count).to eq(4)
      expect(txn.reload.line_items.last.qb_line_id).to eq(3)
      # Adding a debit to the interest receivable account should reduce the
      # change in interest and thus the txn's amount field
      expect(txn.amount).to eq 14.09
    end
  end

  context 'when quickbooks_data is nil' do
    subject do
      create(:accounting_transaction,
        amount: 404.02,
        total: 42,
        txn_date: '2017-10-31',
        private_note: 'a memo',
        description: 'desc',
        project_id: loan.id,
      )
    end

    it 'should not overwrite calculated quickbooks fields' do
      expect(subject.amount).to eq 404.02
      expect(subject.total).to eq 42
      expect(subject.txn_date).to eq Date.parse('2017-10-31')
      expect(subject.private_note).to eq 'a memo'
      expect(subject.description).to eq 'desc'
      expect(subject.project_id).to eq loan.id
    end
  end

  describe '#update' do
    context 'when last_updated_at is nil' do
      let(:last_updated_at) { nil }

      it 'throws error' do
        expect { subject.update }.to raise_error(Accounting::Quickbooks::FullSyncRequiredError)
      end

      context 'when qb_connection is nil' do
        subject { described_class.new(nil) }

        it 'throws error' do
          expect { subject.update }.to raise_error(Accounting::Quickbooks::NotConnectedError)
        end
      end
    end

    context 'when last_updated_at is 31 days ago' do
      let(:last_updated_at) { 31.days.ago }

      it 'throws error' do
        expect { subject.update }.to raise_error(Accounting::Quickbooks::FullSyncRequiredError)
      end
    end

    context 'when last_updated_at is 30 days ago' do
      let(:last_updated_at) { 30.days.ago }

      before do
        allow(subject).to receive(:changes).and_return('JournalEntry' => [journal_entry])
      end

      it 'does not throw error' do
        expect { subject.update }.not_to raise_error
      end

      context 'when transaction does not yet exist locally' do

        it 'creates a new transaction with the correct data' do
          subject.update

          transaction = Accounting::Transaction.where(qb_id: qb_id).take
          expect(transaction).not_to be_nil
          expect(transaction.qb_transaction_type).to eq 'JournalEntry'
          expect(transaction.quickbooks_data).not_to be_empty
        end
      end

      context 'when transaction synced, but was updated in QBO' do
        let!(:journal_entry_transaction) { create(:journal_entry_transaction, qb_id: qb_id, quickbooks_data: quickbooks_data) }
        let(:journal_entry) { instance_double(Quickbooks::Model::JournalEntry, id: qb_id, as_json: updated_quickbooks_data) }
        let(:new_loan) { create(:loan) }
        let(:updated_quickbooks_data) do
          { 'line_items' =>
           [{ 'id' => '0',
              'description' => 'New desc',
              'amount' => '0.24',
              'detail_type' => 'JournalEntryLineDetail',
              'journal_entry_line_detail' => {
                'posting_type' => 'Debit',
                'entity' => {
                  'type' => 'Customer',
                  'entity_ref' => { 'value' => '1', 'name' => "Amy's Bird Sanctuary", 'type' => nil } },
                'account_ref' => { 'value' => '84', 'name' => 'Accounts Receivable (A/R)', 'type' => nil },
                'class_ref' => { 'value' => '5000000000000026437', 'name' => new_loan.id, 'type' => nil },
                'department_ref' => nil } },
            { 'id' => '1',
              'description' => 'Nate desc',
              'amount' => '0.24',
              'detail_type' => 'JournalEntryLineDetail',
              'journal_entry_line_detail' => {
                'posting_type' => 'Credit',
                'entity' => {
                  'type' => 'Customer',
                  'entity_ref' => { 'value' => '1', 'name' => "Amy's Bird Sanctuary", 'type' => nil } },
                'account_ref' => { 'value' => '35', 'name' => 'Checking', 'type' => nil },
                'class_ref' => { 'value' => '5000000000000026437', 'name' => new_loan.id, 'type' => nil },
                'department_ref' => nil } }],
            'id' => '167',
            'sync_token' => 0,
            'meta_data' => {
              'create_time' => '2017-04-18T10:14:30.000-07:00',
              'last_updated_time' => '2017-04-18T10:14:30.000-07:00' },
            'txn_date' => '2017-07-08',
            'total' => '407.22',
            'private_note' => 'New note' }
        end

        it 'does not create a new transaction' do
          expect { subject.update }.not_to change { Accounting::Transaction.where(qb_id: qb_id).count }
        end

        it 'updates transaction timestamp' do
          expect { subject.update }.to change { Accounting::Transaction.where(qb_id: qb_id).take.updated_at }
        end

        it 'updates transaction fields' do
          subject.update
          t = Accounting::Transaction.where(qb_id: qb_id).take

          expect(t.amount).to eq(0.24)
          expect(t.description).to eq('New desc')
          expect(t.project_id).to eq(new_loan.id)
          expect(t.txn_date).to eq(Date.parse('2017-07-08'))
          expect(t.private_note).to eq('New note')
          expect(t.total).to eq(407.22)
        end
      end

      context 'when Transaction created locally, but not synced to QBO' do
        let!(:journal_entry_transaction) { create(:journal_entry_transaction, qb_id: qb_id) }

        context 'with updated JournalEntry' do
          it 'does not create a new transaction' do
            expect { subject.update }.not_to change { Accounting::Transaction.where(qb_id: qb_id).count }
          end

          it 'updates transaction timestamp' do
            expect { subject.update }.to change { Accounting::Transaction.where(qb_id: qb_id).take.updated_at }
          end

          it 'updates transaction fields' do
            subject.update
            t = Accounting::Transaction.where(qb_id: qb_id).take

            expect(t.amount).to eq(15.09)
            expect(t.description).to eq('Nate desc')
            expect(t.project_id).to eq(loan.id)
            expect(t.txn_date).to eq(Date.parse('2017-04-18'))
            expect(t.private_note).to eq('Nate now testing')
            expect(t.total).to eq(19.99)
          end
        end

        context 'with deleted JournalEntry' do
          let(:journal_entry) { instance_double(Quickbooks::Model::ChangeModel, id: qb_id, status: 'Deleted') }

          it 'destroys transaction with the proper qb_id' do
            expect { subject.update }.to change { Accounting::Transaction.where(qb_id: qb_id).count }.by -1
          end
        end
      end
    end
  end
end
