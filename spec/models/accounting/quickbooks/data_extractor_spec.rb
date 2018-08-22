require 'rails_helper'

describe Accounting::Quickbooks::DataExtractor, type: :model do
  context '#extract!' do
    it "calls the right extractor class" do
      txn = create(:accounting_transaction, qb_object_type: "JournalEntry")
      expect(TransactionExtractor).to receive(:new).with(txn)
      described_class.new(txn)
    end
  end
end
