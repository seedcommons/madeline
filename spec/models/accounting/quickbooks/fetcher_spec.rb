require 'rails_helper'

RSpec.describe Accounting::Quickbooks::Fetcher, type: :model do
  let(:valid_token) { 'lvprdxMSsckHORgjp9RCmVaF6anST6VWIVU84eQempNRZy0f' }

  subject { Accounting::Quickbooks::Fetcher.new(transactions) }

  context 'when no transactions exist' do
    let(:transactions) { Accounting::Transaction.all }

    it 'should fetch nothing' do
      expect(subject.fetch).to be_empty
    end
  end

  context 'when one transaction type exists' do
    before do
      allow(subject).to receive(:service).and_return(service)
      allow(service).to receive(:query).and_return(qb_objects)
    end

    let(:service) { instance_double(Quickbooks::Service::Deposit) }
    let(:qb_objects) do
      [
        instance_double(Quickbooks::Model::Deposit, id: 10),
        instance_double(Quickbooks::Model::Deposit, id: 35),
      ]
    end
    let(:transactions) do
      create(:accounting_transaction, qb_transaction_id: 10, qb_transaction_type: 'Deposit')
      create(:accounting_transaction, qb_transaction_id: 35, qb_transaction_type: 'Deposit')
      Accounting::Transaction.all
    end

    it 'should fetch 2 records' do
      expect(subject.fetch.count).to eql 2
    end

    it 'should attach all qb_objects' do
      subject.fetch

      transactions.each do |transaction|
        expect(transaction.qb_object).to_not be_nil
      end
    end
  end

  context 'when multiple transaction types exist' do
    before do
      d_service = instance_double(Quickbooks::Service::Deposit, query: deposits)
      j_service = instance_double(Quickbooks::Service::JournalEntry, query: [instance_double(Quickbooks::Model::JournalEntry, id: 49)])

      allow(subject).to receive(:service).with('Deposit').and_return(d_service)
      allow(subject).to receive(:service).with('JournalEntry').and_return(j_service)
    end

    let(:deposits) do
      [
        instance_double(Quickbooks::Model::Deposit, id: 10),
        instance_double(Quickbooks::Model::Deposit, id: 35),
      ]
    end
    let(:transactions) do
      create(:accounting_transaction, qb_transaction_id: 10, qb_transaction_type: 'Deposit')
      create(:accounting_transaction, qb_transaction_id: 35, qb_transaction_type: 'Deposit')
      create(:accounting_transaction, qb_transaction_id: 49, qb_transaction_type: 'JournalEntry')
      Accounting::Transaction.all
    end

    it 'should fetch 3 records' do
      expect(subject.fetch.count).to eq 3
    end

    it 'should attach all qb_objects' do
      subject.fetch

      transactions.each do |transaction|
        expect(transaction.qb_object).to_not be_nil
      end
    end
  end
end
