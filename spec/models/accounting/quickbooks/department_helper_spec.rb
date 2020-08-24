require 'rails_helper'

RSpec.describe Accounting::QB::DepartmentHelper, type: :model do
  subject { described_class.new }
  let(:division) { create(:division, qb_departmartme) }
  context 'given a division with a qb department' do
    let(:qb_department) { create(:department) }
    let(:division) { create(:division, qb_department: qb_department) }
    it 'returns proper department reference' do
      reference = subject.reference(division)
      expect(reference).to be_a(Quickbooks::Model::BaseReference)
      expect(reference.value).to eq qb_department.qb_id
    end
  end
end
