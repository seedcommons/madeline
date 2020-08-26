# == Schema Information
#
# Table name: accounting_qb_departments
#
#  created_at      :datetime         not null
#  division_id     :bigint(8)
#  id              :bigint(8)        not null, primary key
#  name            :string           not null
#  qb_id           :string           not null
#  quickbooks_data :json
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_accounting_qb_departments_on_division_id  (division_id)
#
# Foreign Keys
#
#  fk_rails_...  (division_id => divisions.id)
#

require 'rails_helper'

RSpec.describe Accounting::QB::Department, type: :model do
  describe "department" do
    let(:division_name) {"Test QB Dept"}
    let(:dept_name) {"Test QB Dept Loans"}
    let(:qb_department_object) {
      instance_double(Quickbooks::Model::Department,
        id: 123,
        sync_token: 0,
        meta_data: {},
        name: dept_name,
        sub_department: false,
        parent_ref: nil,
        fully_qualified_name: "FQ name")
    }
    context "there is a matching name" do
      let!(:division_with_match) { create(:division, name: division_name) }
      it "associates a new qb department with matching division " do
        expect(Accounting::QB::Department.count).to eq 0
        Accounting::QB::Department.create_or_update_from_qb_object!(qb_object_type: "Department", qb_object: qb_department_object)
        expect(Accounting::QB::Department.first.name).to eq dept_name
        expect(Accounting::QB::Department.first.division_id).to eq division_with_match.id
      end
    end

    context "no division has a matching name" do
      let(:unmatched_name) { "doesn't match" }
      let!(:division_without_match) { create(:division, name: unmatched_name) }
      it "saves department with no division" do
        expect(Accounting::QB::Department.count).to eq 0
        Accounting::QB::Department.create_or_update_from_qb_object!(qb_object_type: "Department", qb_object: qb_department_object)
        expect(Accounting::QB::Department.first.name).to eq dept_name
        expect(Accounting::QB::Department.first.division_id).to be nil
      end
    end

    context "building a reference" do
      context 'given a division that does have a qb department' do
        let(:qb_department) { create(:department) }
        let(:division) { create(:division, qb_department: qb_department) }
        it 'returns proper department reference' do
          reference = ::Accounting::QB::Department.reference(division)
          expect(reference).to be_a(Quickbooks::Model::BaseReference)
          expect(reference.value).to eq qb_department.qb_id
        end
      end

      context 'given a division with no qb department' do
        let(:division) { create(:division, qb_department: nil) }
        it 'returns nil' do
          reference = ::Accounting::QB::Department.reference(division)
          expect(reference).to be_nil
        end
      end
    end
  end
end
