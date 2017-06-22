require 'rails_helper'

feature 'transaction flow' do
  let(:user) { create_admin(root_division) }

  before do
    login_as(user, scope: :user)
    allow(Accounting::Quickbooks::Updater).to receive(:new).and_return(updater)
  end

  describe 'all transactions' do
    let(:updater) { instance_double(Accounting::Quickbooks::Updater, last_updated_at: Time.zone.now) }
    let!(:transactions) { create_list(:accounting_transaction, 2) }

    scenario 'loads properly', js: true do
      # Should update transactions
      expect(updater).to receive(:update)

      visit '/admin/accounting/transactions'

      expect(page).to have_content(transactions[0].qb_transaction_type)
    end
  end

  describe 'transactions for loan' do
    let!(:loan) { create(:loan) }
    let(:journal_entry) { instance_double(Quickbooks::Model::JournalEntry, id: 492, as_json: quickbooks_data) }
    let(:connection) { instance_double(Accounting::Quickbooks::Connection) }
    let(:updater) { Accounting::Quickbooks::Updater.new(connection) }
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

    before do
      allow(updater).to receive(:changes).and_return({ 'JournalEntry' => [journal_entry] })
      allow(connection).to receive(:update_attribute)
    end

    scenario 'creates new transaction, when new qbo object is present', js: true do
      visit "/admin/loans/#{loan.id}/transactions"

      # If the QB ID/Type are eventually hidden, this spec will need to some how change to verify those values.
      expect(page).to have_content(492)
      expect(page).to have_content('JournalEntry')
      expect(page).to have_content('2017-04-18')
      expect(page).to have_content(19.99)
      expect(page).to have_content('Nate now testing')
    end
  end
end
