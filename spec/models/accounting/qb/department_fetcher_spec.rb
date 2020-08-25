require 'rails_helper'

RSpec.describe Accounting::QB::DepartmentFetcher, type: :model do
  let(:division) { create(:division) }
  subject { described_class.new(division) }

  it 'should work when a nil query result is returned' do
    service = instance_double(Quickbooks::Service::Department, all: nil)
    allow(subject).to receive(:service).and_return(service)
    expect { subject.fetch }.to_not raise_error
  end

  it 'should fetch all records for Department' do
    service = instance_double(Quickbooks::Service::Department, all: [])
    allow(subject).to receive(:service).and_return(service)
    expect(service).to receive(:all)
    subject.fetch
  end

  context 'with one Department returned' do
    let(:name) { 'Test Department Name' }
    let(:qb_department) { instance_double(Quickbooks::Model::Department, id: 99, name: name) }
    let(:service) { instance_double(Quickbooks::Service::Department, all: [qb_department]) }
    let(:fetcher) { described_class.new(division) }

    subject { fetcher.fetch }

    before do
      allow(fetcher).to receive(:service).with('Department').and_return(service)
    end

    it 'should create Accounting::Department record' do
      expect { subject }.to change { Accounting::QB::Department.all.count }.by(1)
    end

    it 'the Department created has correct qb_id and name' do
      subject

      department = Accounting::QB::Department.where(qb_id: 99).first
      expect(department.name).to eq name
    end
  end
end
