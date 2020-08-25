require 'rails_helper'

RSpec.describe Accounting::QB::AccountFetcher, type: :model do
  let(:division) { create(:division, :with_accounts) }
  subject { described_class.new(division) }

  it 'should work when a nil query result is returned' do
    service = instance_double(Quickbooks::Service::Account, all: nil)
    allow(subject).to receive(:service).and_return(service)
    expect { subject.fetch }.to_not raise_error
  end

  it 'should fetch all records for Account' do
    service = instance_double(Quickbooks::Service::Account, all: [])
    allow(subject).to receive(:service).and_return(service)
    expect(service).to receive(:all)
    subject.fetch
  end

  context 'with one account returned' do
    let(:name) { 'test_account_name' }
    let(:classification) { 'Liability' }
    let(:qb_account) { instance_double(Quickbooks::Model::Account, id: 99, name: name, classification: classification) }
    let(:service) { instance_double(Quickbooks::Service::Account, all: [qb_account]) }
    let(:fetcher) { described_class.new(division) }

    subject { fetcher.fetch }

    before do
      allow(fetcher).to receive(:service).with('Account').and_return(service)
    end

    describe "new qb id" do
      # an qb_id not used elsewhere is needed because rspec order is not guaranteed, so
      # that another spec does not create an account with the same qb_id
      # (in which case find_or_create finds and does not create, and this spec would fail)
      let!(:qb_account) { instance_double(Quickbooks::Model::Account, id: 333, name: name, classification: classification) }

      it 'should create Accounting::Account record' do
        expect { subject }.to change { Accounting::Account.all.count }.by(1)
      end
    end

    it 'the account created has correct name' do
      subject

      account = Accounting::Account.where(qb_id: 99).first
      expect(account.name).to eq name
    end

    it 'the account created has correct classification' do
      subject

      account = Accounting::Account.where(qb_id: 99).first
      expect(account.qb_account_classification).to eq classification
    end
  end
end
