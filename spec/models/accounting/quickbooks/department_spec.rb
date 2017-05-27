require 'rails_helper'

RSpec.describe Accounting::Quickbooks::Department, type: :model do
  let(:department_name) { 'A division with a name' }
  let(:qb_department_id) { '91234' }
  let(:qb_new_department) { instance_double(Quickbooks::Model::Department, id: qb_department_id) }

  subject { described_class.new(division: division, qb_connection: nil) }

  before do
    allow(subject).to receive(:service).and_return(service)
  end

  context 'when qb department does not exist' do
    let(:division) { create(:division, name: department_name) }
    let(:service) { instance_double(Quickbooks::Service::Department, create: qb_new_department) }

    it 'creates Department using name' do
      expect(service).to receive(:create) do |arg|
        expect(arg.name).to eq department_name
      end.and_return(qb_new_department)

      subject.reference
    end

    it 'returns proper department reference' do
      allow(service).to receive(:create).and_return(qb_new_department)

      reference = subject.reference
      expect(reference.value).to eq qb_department_id
    end

    it 'saves qb_id to organization' do
      allow(service).to receive(:create).and_return(qb_new_department)

      subject.reference
      expect(Division.where(qb_id: qb_department_id).count).to eq 1
    end
  end

  context 'when qb department does exist' do
    let(:division) { create(:division, qb_id: qb_department_id) }
    let(:service) { instance_double(Quickbooks::Service::Department, create: nil) }

    it 'does not create a department' do
      expect(service).not_to receive(:create)
      subject.reference
    end

    it 'returns proper department reference' do
      allow(service).to receive(:create).and_return(qb_new_department)

      reference = subject.reference
      expect(reference.value).to eq qb_department_id
    end
  end
end
