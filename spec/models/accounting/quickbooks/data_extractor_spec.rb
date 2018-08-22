require 'rails_helper'

describe Accounting::Quickbooks::DataExtractor, type: :model do
  context '#extract!' do
    %w(JournalEntry Purchase Deposit Bill).each do |obj_type|
      it "calls the right extractor class for #{obj_type}" do
        txn = create(:accounting_transaction, qb_object_type: obj_type)
        expect(Accounting::Quickbooks::TransactionExtractor).to receive(:new).with(txn)
        described_class.new(txn)
      end
    end
  end
end
