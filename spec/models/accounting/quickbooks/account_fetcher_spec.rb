require 'rails_helper'

RSpec.describe Accounting::Quickbooks::AccountFetcher, type: :model do
  subject { described_class.new }

  it 'should fetch all records for Account' do
    service = instance_double(Quickbooks::Service::Account)
    allow(subject).to receive(:service).and_return(service)
    expect(service).to receive(:all).and_return([])
    subject.fetch
  end
end
