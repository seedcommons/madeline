require 'rails_helper'

RSpec.describe Accounting::Transaction, type: :model do
  # subject { described_class.new(instance_double(Accounting::Quickbooks::Connection)) }
  let(:loan) { create(:loan) }
  let(:transaction) { create(:accounting_transaction) }
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
        'description' => 'Nate desc',
        'amount' => '15.09',
        'detail_type' => 'JournalEntryLineDetail',
        'journal_entry_line_detail' => {
          'posting_type' => 'Credit',
          'entity' => {
            'type' => 'Customer',
            'entity_ref' => { 'value' => '1', 'name' => "Amy's Bird Sanctuary", 'type' => nil } },
          'account_ref' => { 'value' => '35', 'name' => 'Checking', 'type' => nil },
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

  context 'when quickbooks_data is updated' do
    subject do
      transaction.tap { transaction.update(quickbooks_data: quickbooks_data) }
    end

    it 'updates amount' do
      expect(subject.amount).to eq 15.09
    end

    it 'updates total' do
      expect(subject.total).to eq 19.99
    end

    it 'updates txn_date' do
      expect(subject.txn_date).to eq Date.parse('2017-04-18')
    end

    it 'updates private_note' do
      expect(subject.private_note).to eq 'Nate now testing'
    end

    it 'updates description' do
      expect(subject.description).to eq 'Nate desc'
    end

    it 'updates project_id' do
      expect(subject.project_id).to eq loan.id
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
end
