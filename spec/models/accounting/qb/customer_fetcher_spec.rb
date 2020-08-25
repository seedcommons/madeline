require 'rails_helper'

RSpec.describe Accounting::QB::CustomerFetcher, type: :model do
  let(:division) { create(:division) }
  subject { described_class.new(division) }

  it 'should work when a nil query result is returned' do
    service = instance_double(Quickbooks::Service::Customer, all: nil)
    allow(subject).to receive(:service).and_return(service)
    expect { subject.fetch }.to_not raise_error
  end

  it 'should fetch all records for Customer' do
    service = instance_double(Quickbooks::Service::Customer, all: [])
    allow(subject).to receive(:service).and_return(service)
    expect(service).to receive(:all)
    subject.fetch
  end

  context 'with one Customer returned' do
    let(:name) { 'Test Customer Name' }
    let(:qb_customer) { instance_double(Quickbooks::Model::Customer, id: 99, display_name: name) }
    let(:service) { instance_double(Quickbooks::Service::Customer, all: [qb_customer]) }
    let(:fetcher) { described_class.new(division) }

    subject { fetcher.fetch }

    before do
      allow(fetcher).to receive(:service).with('Customer').and_return(service)
    end

    it 'should create Accounting::Customer record' do
      expect { subject }.to change { Accounting::Customer.all.count }.by(1)
    end

    it 'the Customer created has correct qb_id and name' do
      subject

      Customer = Accounting::Customer.where(qb_id: 99).first
      expect(Customer.name).to eq name
    end
  end
end
