require 'rails_helper'

describe Accounting::Quickbooks::DataExtractor, type: :model do
  it "raises an error with invalid object type" do
    txn = create(:accounting_transaction, qb_object_type: "ChocolateStout")
    expect { described_class.new(txn) }.to raise_error(RuntimeError)
  end

  context '#extract!' do
    %w(JournalEntry Deposit Purchase Bill).each do |obj_type|
      it "calls the right extractor class for #{obj_type}" do
        txn = create(:accounting_transaction, qb_object_type: obj_type)
        extractor = double("extractor")
        expect("Accounting::Quickbooks::#{obj_type}Extractor".constantize).to receive(:new).with(txn) { extractor }
        expect(extractor).to receive(:extract!)
        described_class.new(txn).extract!
      end
    end
  end
end
