require 'rails_helper'

RSpec.describe Accounting::Quickbooks::Updater, type: :model do
  let(:connection) { instance_double(Accounting::Quickbooks::Connection, last_updated_at: last_updated_at) }
  let(:generic_service) { instance_double(Quickbooks::Service::ChangeDataCapture, since: double(all_types: [])) }
  let(:qb_id) { 34 }
  let(:division) { create(:division, :with_accounts) }
  let(:prin_acct) { division.principal_account}
  let(:int_rcv_acct) { division.interest_receivable_account }
  let(:loan) { create(:loan, division: division) }
  let(:journal_entry) { instance_double(Quickbooks::Model::JournalEntry, id: qb_id, as_json: quickbooks_data) }
  let(:last_updated_at) { nil }
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
          'account_ref' => { 'value' => '35', 'name' => prin_acct.name, 'type' => nil },
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
           'account_ref' => { 'value' => '35', 'name' => int_rcv_acct.name, 'type' => nil },
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
  let(:txn) { create(:accounting_transaction, project: loan, quickbooks_data: quickbooks_data) }
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
        account: prin_acct,
        posting_type: 'Credit'),
      create(:line_item,
        qb_line_id: 2,
        description: 'Jay desc',
        amount: '2.72',
        account: int_rcv_acct,
        posting_type: 'Credit')]
  end

  subject { described_class.new(connection) }

  before do
    allow(subject).to receive(:service).and_return(generic_service)
    allow(connection).to receive(:update_attribute).with(:last_updated_at, anything)
  end

  context 'QB line item manipulations' do
    context 'line item added' do

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
            'account_ref' => { 'value' => '84', 'name' => int_rcv_acct.name, 'type' => nil },
            'class_ref' => { 'value' => '5000000000000026437', 'name' => loan.id, 'type' => nil },
            'department_ref' => nil } }

        txn.update(quickbooks_data: quickbooks_data)
        subject.send(:extract_qb_data, txn)
      end

      it 'updates correctly in Madeline' do
        expect(txn.reload.line_items.count).to eq(4)
        expect(txn.reload.line_items.last.qb_line_id).to eq(3)

        # Adding a debit to the interest receivable account should reduce the
        # change in interest and thus the txn's amount field
        expect(txn.reload.amount).to eq 16.09
      end
    end

    context 'line item updated' do
      let(:last_updated_at) { Date.today - 3 }

      before do
        line_item = quickbooks_data['line_items'][1]

        # update a line item
        line_item['journal_entry_line_detail']['posting_type'] = 'Debit'
        line_item['amount'] = 10.00

        txn.update(quickbooks_data: quickbooks_data)
        subject.send(:extract_qb_data, txn)
      end

      it 'updates correctly in Madeline' do
        expect(txn.reload.line_items.count).to eq(3)
        expect(txn.reload.line_items.last.qb_line_id).to eq(2)
        expect(txn.reload.line_items.map {|i| i.posting_type}).to contain_exactly('Debit', 'Debit', 'Credit')
        expect(txn.reload.line_items.map {|i| i.amount}).to contain_exactly(15.09, 10.00, 2.72)

        # Adding a debit to the interest receivable account should reduce the
        # change in interest and thus the txn's amount field
        expect(txn.reload.amount).to eq 12.72
      end
    end

    context 'line items removed' do
      let(:last_updated_at) { Date.today - 2 }

      before do
        line_item = quickbooks_data['line_items'][1]
        line_item_2 = quickbooks_data['line_items'][2]

        # remove line items
        quickbooks_data['line_items'].delete(line_item)
        quickbooks_data['line_items'].delete(line_item_2)

        txn.update(quickbooks_data: quickbooks_data)
        subject.send(:extract_qb_data, txn)
      end

      it 'updates correctly in Madeline' do
        expect(txn.reload.line_items.count).to eq(1)
        expect(txn.reload.line_items.last.qb_line_id).to eq(0)

        # Adding a debit to the interest receivable account should reduce the
        # change in interest and thus the txn's amount field
        expect(txn.reload.amount).to eq 0
      end
    end
  end

  describe '#update' do
    context 'when last_updated_at is nil' do
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
          expect { subject.update }.to change { Accounting::Transaction.find_by(qb_id: qb_id).updated_at }
        end

        it 'updates transaction fields' do
          subject.update

          t = Accounting::Transaction.find_by(qb_id: qb_id)
          expect(t.quickbooks_data).to eq(updated_quickbooks_data)
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

            expect(t.quickbooks_data).to eq(quickbooks_data)
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
