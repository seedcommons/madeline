require 'rails_helper'

# TODO: find a way to stub less of this workflow/add more unit tests.
# The specs are not catching when the update method receives a loan or an array of loans

RSpec.describe Accounting::Quickbooks::Updater, type: :model do
  let(:generic_service) { instance_double(Quickbooks::Service::ChangeDataCapture, since: double(all_types: [])) }
  let(:qb_id) { 1982547353 }
  let(:division) { create(:division, :with_accounts) }
  let(:prin_acct) { division.principal_account}
  let(:int_inc_acct) { division.interest_income_account }
  let(:int_rcv_acct) { division.interest_receivable_account }
  let(:txn_acct) { create(:account, name: 'Some Bank Account') }
  let(:loan) { create(:loan, division: division) }
  let(:journal_entry) { instance_double(Quickbooks::Model::JournalEntry, id: qb_id, as_json: quickbooks_data) }

  # This is example JSON that might be returned by the QB API.
  # The data are taken from the docs/example_calculation.xlsx file, row 7.
  let(:quickbooks_data) do
    { 'line_items' =>
     [{ 'id' => '0',
        'description' => 'Repayment',
        'amount' => '10.99',
        'detail_type' => 'JournalEntryLineDetail',
        'journal_entry_line_detail' => {
          'posting_type' => 'Credit',
          'entity' => {
            'type' => 'Customer',
            'entity_ref' => { 'value' => '1', 'name' => "Amy's Bird Sanctuary", 'type' => nil } },
          'account_ref' => { 'value' => prin_acct.qb_id, 'name' => prin_acct.name, 'type' => nil },
          'class_ref' => { 'value' => '5000000000000026437', 'name' => loan.id, 'type' => nil },
          'department_ref' => nil } },
      { 'id' => '1',
        'description' => 'Repayment',
        'amount' => '1.31',
        'detail_type' => 'JournalEntryLineDetail',
        'journal_entry_line_detail' => {
          'posting_type' => 'Credit',
          'entity' => {
            'type' => 'Customer',
            'entity_ref' => { 'value' => '1', 'name' => "Amy's Bird Sanctuary", 'type' => nil } },
          'account_ref' => { 'value' => int_rcv_acct.qb_id, 'name' => int_rcv_acct.name, 'type' => nil },
          'class_ref' => { 'value' => '5000000000000026437', 'name' => loan.id, 'type' => nil },
          'department_ref' => nil } },
       { 'id' => '2',
         'description' => 'Repayment',
         'amount' => '12.30',
         'detail_type' => 'JournalEntryLineDetail',
         'journal_entry_line_detail' => {
           'posting_type' => 'Debit',
           'entity' => {
             'type' => 'Customer',
             'entity_ref' => { 'value' => '1', 'name' => "Amy's Bird Sanctuary", 'type' => nil } },
           'account_ref' => { 'value' => txn_acct.qb_id, 'name' => txn_acct.name, 'type' => nil },
           'class_ref' => { 'value' => '5000000000000026437', 'name' => loan.id, 'type' => nil },
           'department_ref' => nil } }],
      'id' => '167',
      'sync_token' => 0,
      'meta_data' => {
        'create_time' => '2017-04-18T10:14:30.000-07:00',
        'last_updated_time' => '2017-04-18T10:14:30.000-07:00' },
      'txn_date' => '2017-04-18',
      'total' => '12.30',
      'doc_number' => 'textme',
      'private_note' => 'Random stuff' }
  end

  let(:txn) { create(:accounting_transaction, project: loan, quickbooks_data: quickbooks_data) }

  # These line items match the JSON above.
  let!(:line_items) do
    txn.line_items = [create(:line_item,
        qb_line_id: 0,
        amount: '10.99',
        account: prin_acct,
        posting_type: 'Credit'),
      create(:line_item,
        qb_line_id: 1,
        amount: '1.31',
        account: int_rcv_acct,
        posting_type: 'Credit'),
      create(:line_item,
        qb_line_id: 2,
        amount: '12.30',
        account: txn_acct,
        posting_type: 'Debit')]
  end

  subject { described_class.new(division.qb_connection) }

  before do
    allow(subject).to receive(:service).and_return(generic_service)
    allow(division).to receive(:qb_division).and_return(division)
  end

  # TODO: extract_qb_data should move out of Updater and into a separate Extractor class.
  # When it does, this context block should move into a separate spec.
  context '#extract_qb_data' do
    context 'adding 1.00 credit to int_rcv_acct and 1.00 debit to txn_acct in quickbooks' do
      before do
        quickbooks_data['line_items'] << {
          'id' => '3',
          'description' => 'Repayment',
          'amount' => '1.00',
          'detail_type' => 'JournalEntryLineDetail',
          'journal_entry_line_detail' => {
            'posting_type' => 'Credit',
            'entity' => {
              'type' => 'Customer',
              'entity_ref' => { 'value' => '1', 'name' => "Amy's Bird Sanctuary", 'type' => nil } },
            'account_ref' => { 'value' => int_rcv_acct.qb_id, 'name' => int_rcv_acct.name, 'type' => nil },
            'class_ref' => { 'value' => '5000000000000026437', 'name' => loan.id, 'type' => nil },
            'department_ref' => nil } }
        quickbooks_data['line_items'] << {
          'id' => '4',
          'description' => 'Repayment',
          'amount' => '1.00',
          'detail_type' => 'JournalEntryLineDetail',
          'journal_entry_line_detail' => {
            'posting_type' => 'Debit',
            'entity' => {
              'type' => 'Customer',
              'entity_ref' => { 'value' => '1', 'name' => "Amy's Bird Sanctuary", 'type' => nil } },
            'account_ref' => { 'value' => txn_acct.qb_id, 'name' => txn_acct.name, 'type' => nil },
            'class_ref' => { 'value' => '5000000000000026437', 'name' => loan.id, 'type' => nil },
            'department_ref' => nil } }
        quickbooks_data['total'] = '13.30'
        update_transaction_with_new_quickbooks_data
      end

      it 'updates correctly in Madeline' do
        expect(txn.line_items.map(&:qb_line_id)).to eq([0, 1, 2, 3, 4])
        expect(txn.line_items.map(&:posting_type)).to eq(['Credit', 'Credit', 'Debit', 'Credit', 'Debit'])
        expect_line_item_amounts([10.99, 1.31, 12.30, 1.00, 1.00])

        # Amount is calculated from line items so this tests all of those calculations.
        expect(txn.amount).to equal_money(13.30)
      end
    end

    context 'changing existing prin_acct and txn_acct line items by 0.50 in quickbooks' do
      before do
        quickbooks_data['line_items'][1]['amount'] = '0.81' # int_rcv_acct
        quickbooks_data['line_items'][2]['amount'] = '11.80' # txn_acct
        quickbooks_data['total'] = '11.80'

        # We throw in an account name change also to test that accounts are matched by ID.
        # This should not affect anything.
        quickbooks_data['line_items'][1]['journal_entry_line_detail']['account_ref']['name'] = 'Foo'

        update_transaction_with_new_quickbooks_data
      end

      it 'updates correctly in Madeline' do
        expect(txn.line_items.map(&:qb_line_id)).to eq([0, 1, 2])
        expect(txn.line_items.map(&:posting_type)).to eq(['Credit', 'Credit', 'Debit'])
        expect_line_item_amounts([10.99, 0.81, 11.80])
        expect(txn.amount).to equal_money(11.80)
      end
    end

    context 'removing a credit and and adjusting the other credit in quickbooks' do
      before do
        quickbooks_data['line_items'][0]['amount'] = '9.68'
        quickbooks_data['line_items'][2]['amount'] = '9.68'
        quickbooks_data['line_items'].delete_at(1)
        quickbooks_data['total'] = '9.68'
        update_transaction_with_new_quickbooks_data
      end

      it 'updates correctly in Madeline' do
        expect(txn.line_items.map(&:qb_line_id)).to eq([0, 2])
        expect(txn.line_items.map(&:posting_type)).to eq(['Credit', 'Debit'])
        expect_line_item_amounts([9.68, 9.68])
        expect(txn.amount).to equal_money(9.68)
      end
    end

    context 'journal number without MS prefix is unmanaged' do
      it do
        expect(txn.managed).to be false
      end
    end

    def update_transaction_with_new_quickbooks_data
      txn.update(quickbooks_data: quickbooks_data)
      subject.send(:extract_qb_data, txn)
      txn.calculate_balances
      txn.save!
      txn.reload
    end

    def expect_line_item_amounts(amounts)
      amounts.each_with_index do |amt, i|
        expect(txn.line_items[i].amount).to equal_money(amt)
      end
    end
  end

  describe '#update' do
    let(:last_updated_at) { nil }

    before do
      division.qb_connection.update_attribute(:last_updated_at, last_updated_at)
    end

    context 'when last_updated_at is nil' do
      it 'throws error' do
        expect { subject.update }.to raise_error(Accounting::Quickbooks::DataResetRequiredError)
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
        expect { subject.update }.to raise_error(Accounting::Quickbooks::DataResetRequiredError)
      end
    end

    context 'when last_updated_at is less than 5 seconds ago' do
      let(:last_updated_at) { 4.seconds.ago }

      it 'returns without doing anything' do
        expect(subject).not_to receive(:changes)
        subject.update
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
          expect(transaction.qb_object_type).to eq 'JournalEntry'
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
            'doc_number' => 'MS-textme',
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

        context 'journal number without MS prefix is managed' do
          it do
            expect(txn.managed).to be true
          end
        end
      end
    end
  end
end
