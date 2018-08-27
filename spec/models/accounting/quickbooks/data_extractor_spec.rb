require 'rails_helper'

describe Accounting::Quickbooks::DataExtractor, type: :model do
  it "raises an error with invalid object type" do
    txn = create(:accounting_transaction, qb_object_type: "ChocolateStout")
    expect { described_class.new(txn) }.to raise_error(RuntimeError)
  end

  context '#extract!' do
    %w(JournalEntry Purchase Deposit Bill).each do |obj_type|
      it "calls the right extractor class for #{obj_type}" do
        txn = create(:accounting_transaction, qb_object_type: obj_type)
        extractor = double("extractor")
        expect(Accounting::Quickbooks::TransactionExtractor).to receive(:new).with(txn) { extractor }
        expect(extractor).to receive(:extract!)
        described_class.new(txn).extract!
      end
    end

    # Eventually account extraction should move to another subclass
    # it "calls the right extractor class for Account" do
    #   account = create(:accounting_account)
    #   expect(Accounting::Quickbooks::AccountExtractor).to receive(:new).with(account)
    #   described_class.new(account).extract!
    # end
  end
end
