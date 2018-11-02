require 'rails_helper'

describe Accounting::Quickbooks::JournalEntryExtractor, type: :model do
  let(:qb_id) { 1982547353 }
  let(:division) { create(:division, :with_accounts) }
  let(:prin_acct) { division.principal_account}
  let(:int_inc_acct) { division.interest_income_account }
  let(:int_rcv_acct) { division.interest_receivable_account }
  let(:txn_acct) { create(:account, name: 'Some Bank Account') }
  let(:random_acct) { create(:account, name: 'Another Bank Account') }
  let(:loan) { create(:loan, division: division) }

  # This is example Journal entry JSON that might be returned by the QB API.
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
      'private_note' => 'Random stuff' }
  end

  let(:txn) { create(:accounting_transaction, project: loan, quickbooks_data: quickbooks_data) }
  subject { described_class.new(txn) }

  context '#extract!' do
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

    def update_transaction_with_new_quickbooks_data
      txn.update(quickbooks_data: quickbooks_data)
      subject.extract!
      txn.save!
      txn.reload
    end

    def expect_line_item_amounts(amounts)
      amounts.each_with_index do |amt, i|
        expect(txn.line_items[i].amount).to equal_money(amt)
      end
    end

    context '#txn_type' do
      let(:txn) { Accounting::Transaction.new(project: loan, managed: true, quickbooks_data: quickbooks_data, loan_transaction_type_value: nil) }

      subject { described_class.new(txn) }
      before do
        txn.update(quickbooks_data: quickbooks_data)
        subject.extract!
        txn.save(validate: false)
        txn.reload
      end

      describe 'interest accrual' do
        let(:quickbooks_data) do
          { 'line_items' =>
            [{ 'id' => '0',
              'description' => 'Eba',
              'amount' => '10.99',
              'detail_type' => 'JournalEntryLineDetail',
              'journal_entry_line_detail' => {
                'posting_type' => 'Debit',
                'entity' => {
                  'type' => 'Customer',
                  'entity_ref' => { 'value' => '1', 'name' => "Amy's Bird Sanctuary", 'type' => nil } },
                'account_ref' => { 'value' => int_rcv_acct.qb_id, 'name' => int_rcv_acct.name, 'type' => nil },
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
                  'account_ref' => { 'value' => int_inc_acct.qb_id, 'name' => int_inc_acct.name, 'type' => nil },
                  'class_ref' => { 'value' => '5000000000000026437', 'name' => loan.id, 'type' => nil },
                  'department_ref' => nil } }],
            'id' => '167',
            'sync_token' => 0,
            'meta_data' => {
              'create_time' => '2017-04-18T10:14:30.000-07:00',
              'last_updated_time' => '2017-04-18T10:14:30.000-07:00' },
            'txn_date' => '2017-04-18',
            'total' => '12.30',
            'doc_number' => 'MS-Automatic',
            'private_note' => 'Random stuff' }
        end

        it "has type interest and is managed" do
          expect(txn.loan_transaction_type_value).to eq('interest')
          expect(txn.account).to be nil
          expect(txn.managed).to be true
        end
      end

      describe 'disbursement' do
        let(:quickbooks_data) do
          { 'line_items' =>
            [{ 'id' => '0',
              'description' => 'Eba',
              'amount' => '10.99',
              'detail_type' => 'JournalEntryLineDetail',
              'journal_entry_line_detail' => {
                'posting_type' => 'Credit',
                'entity' => {
                  'type' => 'Customer',
                  'entity_ref' => { 'value' => '1', 'name' => "Amy's Bird Sanctuary", 'type' => nil } },
                'account_ref' => { 'value' => txn_acct.qb_id, 'name' => txn_acct.name, 'type' => nil },
                'class_ref' => { 'value' => '5000000000000026437', 'name' => loan.id, 'type' => nil },
                'department_ref' => nil } },
              { 'id' => '1',
                'description' => 'Repayment',
                'amount' => '1.31',
                'detail_type' => 'JournalEntryLineDetail',
                'journal_entry_line_detail' => {
                  'posting_type' => 'Debit',
                  'entity' => {
                    'type' => 'Customer',
                    'entity_ref' => { 'value' => '1', 'name' => "Amy's Bird Sanctuary", 'type' => nil } },
                  'account_ref' => { 'value' => prin_acct.qb_id, 'name' => prin_acct.name, 'type' => nil },
                  'class_ref' => { 'value' => '5000000000000026437', 'name' => loan.id, 'type' => nil },
                  'department_ref' => nil } }],
            'id' => '167',
            'sync_token' => 0,
            'meta_data' => {
              'create_time' => '2017-04-18T10:14:30.000-07:00',
              'last_updated_time' => '2017-04-18T10:14:30.000-07:00' },
            'txn_date' => '2017-04-18',
            'total' => '12.30',
            'doc_number' => 'MS-Managed',
            'private_note' => 'Random stuff' }
        end

        it do
          expect(txn.loan_transaction_type_value).to eq('disbursement')
          expect(txn.account).to eq txn_acct
          expect(txn.managed).to be true
        end
      end

      describe 'repayment' do
        let(:quickbooks_data) do
          { 'line_items' =>
            [{ 'id' => '0',
              'description' => 'Eba',
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
                'description' => 'Eba',
                'amount' => '10.99',
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
                'amount' => '1.31',
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
            'doc_number' => 'MS-Managed',
            'private_note' => 'Random stuff' }
        end

        it do
          expect(txn.loan_transaction_type_value).to eq('repayment')
          expect(txn.account).to eq txn_acct
          expect(txn.managed).to be true
        end
      end

      context 'too many  line items' do
        # this has all possible scenario for interest, disbursement, repayment and random
        let(:quickbooks_data) do
          { 'line_items' =>
            [{ 'id' => '0',
              'description' => 'Eba',
              'amount' => '10.99',
              'detail_type' => 'JournalEntryLineDetail',
              'journal_entry_line_detail' => {
                'posting_type' => 'Debit',
                'entity' => {
                  'type' => 'Customer',
                  'entity_ref' => { 'value' => '1', 'name' => "Amy's Bird Sanctuary", 'type' => nil } },
                'account_ref' => { 'value' => int_rcv_acct.qb_id, 'name' => int_rcv_acct.name, 'type' => nil },
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
                  'account_ref' => { 'value' => int_inc_acct.qb_id, 'name' => int_inc_acct.name, 'type' => nil },
                  'class_ref' => { 'value' => '5000000000000026437', 'name' => loan.id, 'type' => nil },
                  'department_ref' => nil } },
              { 'id' => '2',
                'description' => 'Eba',
                'amount' => '10.99',
                'detail_type' => 'JournalEntryLineDetail',
                'journal_entry_line_detail' => {
                  'posting_type' => 'Credit',
                  'entity' => {
                    'type' => 'Customer',
                    'entity_ref' => { 'value' => '1', 'name' => "Amy's Bird Sanctuary", 'type' => nil } },
                  'account_ref' => { 'value' => int_rcv_acct.qb_id, 'name' => int_rcv_acct.name, 'type' => nil },
                  'class_ref' => { 'value' => '5000000000000026437', 'name' => loan.id, 'type' => nil },
                  'department_ref' => nil } },
              { 'id' => '3',
                'description' => 'Repayment',
                'amount' => '1.31',
                'detail_type' => 'JournalEntryLineDetail',
                'journal_entry_line_detail' => {
                  'posting_type' => 'Debit',
                  'entity' => {
                    'type' => 'Customer',
                    'entity_ref' => { 'value' => '1', 'name' => "Amy's Bird Sanctuary", 'type' => nil } },
                  'account_ref' => { 'value' => txn_acct.qb_id, 'name' => txn_acct.name, 'type' => nil },
                  'class_ref' => { 'value' => '5000000000000026437', 'name' => loan.id, 'type' => nil },
                  'department_ref' => nil } },
              { 'id' => '4',
                'description' => 'Repayment',
                'amount' => '2.31',
                'detail_type' => 'JournalEntryLineDetail',
                'journal_entry_line_detail' => {
                  'posting_type' => 'Credit',
                  'entity' => {
                    'type' => 'Customer',
                    'entity_ref' => { 'value' => '1', 'name' => "Amy's Bird Sanctuary", 'type' => nil } },
                  'account_ref' => { 'value' => txn_acct.qb_id, 'name' => txn_acct.name, 'type' => nil },
                  'class_ref' => { 'value' => '5000000000000026437', 'name' => loan.id, 'type' => nil },
                  'department_ref' => nil } },
              { 'id' => '5',
                'description' => 'Eba',
                'amount' => '10.99',
                'detail_type' => 'JournalEntryLineDetail',
                'journal_entry_line_detail' => {
                  'posting_type' => 'Debit',
                  'entity' => {
                    'type' => 'Customer',
                    'entity_ref' => { 'value' => '1', 'name' => "Amy's Bird Sanctuary", 'type' => nil } },
                  'account_ref' => { 'value' => prin_acct.qb_id, 'name' => prin_acct.name, 'type' => nil },
                  'class_ref' => { 'value' => '5000000000000026437', 'name' => loan.id, 'type' => nil },
                  'department_ref' => nil } },
              { 'id' => '7',
                'description' => 'Eba',
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
              { 'id' => '8',
                'description' => 'Eba',
                'amount' => '10.99',
                'detail_type' => 'JournalEntryLineDetail',
                'journal_entry_line_detail' => {
                  'posting_type' => 'Credit',
                  'entity' => {
                    'type' => 'Customer',
                    'entity_ref' => { 'value' => '1', 'name' => "Amy's Bird Sanctuary", 'type' => nil } },
                  'account_ref' => { 'value' => random_acct.name, 'name' => random_acct.name, 'type' => nil },
                  'class_ref' => { 'value' => '5000000000000026437', 'name' => loan.id, 'type' => nil },
                  'department_ref' => nil } }],
            'id' => '167',
            'sync_token' => 0,
            'meta_data' => {
              'create_time' => '2017-04-18T10:14:30.000-07:00',
              'last_updated_time' => '2017-04-18T10:14:30.000-07:00' },
            'txn_date' => '2017-04-18',
            'doc_number' => 'Random stuff',
            'total' => '12.30',
            'private_note' => 'Random stuff' }
        end

        it do
          expect(txn.loan_transaction_type_value).to eq('other')
          expect(txn.account).to be nil
          expect(txn.managed).to be false
        end
      end

      describe 'too few line items' do
        let(:quickbooks_data) do
          { 'line_items' =>
            [{ 'id' => '0',
              'description' => 'Eba',
              'amount' => '10.99',
              'detail_type' => 'JournalEntryLineDetail',
              'journal_entry_line_detail' => {
                'posting_type' => 'Credit',
                'entity' => {
                  'type' => 'Customer',
                  'entity_ref' => { 'value' => '1', 'name' => "Amy's Bird Sanctuary", 'type' => nil } },
                'account_ref' => { 'value' => txn_acct.qb_id, 'name' => txn_acct.name, 'type' => nil },
                'class_ref' => { 'value' => '5000000000000026437', 'name' => loan.id, 'type' => nil },
                'department_ref' => nil } },
            ],
            'id' => '167',
            'sync_token' => 0,
            'meta_data' => {
              'create_time' => '2017-04-18T10:14:30.000-07:00',
              'last_updated_time' => '2017-04-18T10:14:30.000-07:00' },
            'txn_date' => '2017-04-18',
            'total' => '12.30',
            'private_note' => 'Random stuff' }
        end

        it do
          expect(txn.loan_transaction_type_value).to eq('other')
          expect(txn.managed).to be false
        end
      end
    end
  end
end
