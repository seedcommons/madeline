# == Schema Information
#
# Table name: loan_questions
#
#  created_at            :datetime         not null
#  data_type             :string
#  has_embeddable_media  :boolean          default(FALSE), not null
#  id                    :integer          not null, primary key
#  internal_name         :string
#  loan_question_set_id  :integer
#  migration_position    :integer
#  override_associations :boolean          default(FALSE), not null
#  parent_id             :integer
#  position              :integer
#  required              :boolean          default(FALSE), not null
#  status                :string           default("active"), not null
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_loan_questions_on_loan_question_set_id  (loan_question_set_id)
#
# Foreign Keys
#
#  fk_rails_a32cf017b9  (loan_question_set_id => loan_question_sets.id)
#

require 'rails_helper'

describe LoanQuestion, :type => :model do
  it 'has a valid factory' do
    expect(create(:loan_question)).to be_valid
  end

  describe 'required_for?' do
    let!(:loan_type_set) { create(:option_set, division: root_division, model_type: ::Loan.name, model_attribute: 'loan_type') }
    let!(:lt1) { create(:option, option_set: loan_type_set, value: 'lt1', label_translations: {en: 'Loan Type One'}) }
    let!(:lt2) { create(:option, option_set: loan_type_set, value: 'lt2', label_translations: {en: 'Loan Type Two'}) }

    let!(:loan1) { create(:loan, loan_type_value: lt1.value)}
    let!(:loan2) { create(:loan, loan_type_value: lt2.value)}

    let!(:set) { create(:loan_question_set) }
    let!(:lqroot) { create(:loan_question, loan_question_set: set, internal_name: "lqroot", data_type: "group") }
    let!(:f1) { create(:loan_question, loan_question_set: set, parent: lqroot, internal_name: "f1", data_type: "text") }

    let!(:f2) { create(:loan_question, loan_question_set: set, parent: lqroot, internal_name: "f4", data_type: "text",
      override_associations: true, loan_types: [lt1,lt2]) }

    let!(:f3) { create(:loan_question, loan_question_set: set, parent: lqroot, internal_name: "f3", data_type: "group",
      override_associations: true, loan_types: [lt1]) }
    let!(:f31) { create(:loan_question, loan_question_set: set, parent: f3, internal_name: "f31", data_type: "string") }
    let!(:f33) { create(:loan_question, loan_question_set: set, parent: f3, internal_name: "f33", data_type: "group") }
    let!(:f331) { create(:loan_question, loan_question_set: set, parent: f33, internal_name: "f331", data_type: "boolean") }
    let!(:f332) { create(:loan_question, loan_question_set: set, parent: f33, internal_name: "f332", data_type: "number",
      override_associations: true, loan_types: [lt2]) }
    let!(:f333) { create(:loan_question, loan_question_set: set, parent: f33, internal_name: "f333", data_type: "text",
      override_associations: true) }

    let!(:f4) { create(:loan_question, loan_question_set: set, parent: f1, internal_name: "f4", data_type: "text",
      loan_types: [lt1,lt2]) }

    it 'not required by default' do
      expect(f1.required_for?(loan1)).to be_falsey
    end

    it 'required when override true and assocation present' do
      expect(f3.required_for?(loan1)).to be_truthy
    end

    it 'not required when override true and assocation not present' do
      expect(f3.required_for?(loan2)).to be_falsey
    end

    it 'required when inherited and parent association present' do
      expect(f31.required_for?(loan1)).to be_truthy
    end

    it 'not required when inherited and parent association not present' do
      expect(f31.required_for?(loan2)).to be_falsey
    end

    it 'not required when override true for child and not present at child level' do
      expect(f332.required_for?(loan1)).to be_falsey
    end

    it 'required when override true for child and present at child level' do
      expect(f332.required_for?(loan2)).to be_truthy
    end

    it 'required when override true and association present for both types' do
      expect(f2.required_for?(loan2)).to be_truthy
    end

    it 'not required when override true for child and no associations present' do
      expect(f333.required_for?(loan1)).to be_falsey
    end

    it 'not required on child when override false even when association is present' do
      expect(f4.required_for?(loan1)).to be_falsey
    end
  end

  describe 'position' do
    let!(:set) { create(:loan_question_set) }
    let!(:lqroot) { create(:loan_question, loan_question_set: set, internal_name: "lqroot", data_type: "group") }
    let!(:f1) { create(:loan_question, loan_question_set: set, parent: lqroot, internal_name: "f1", data_type: "text") }
    let!(:f2) { create(:loan_question, loan_question_set: set, parent: lqroot, internal_name: "f2", data_type: "text",
      override_associations: true) }
    let!(:f3) { create(:loan_question, loan_question_set: set, parent: lqroot, internal_name: "f3", data_type: "group",
      override_associations: true) }
    let!(:f31) { create(:loan_question, loan_question_set: set, parent: f3, internal_name: "f31", data_type: "string") }
    let!(:f32) { create(:loan_question, loan_question_set: set, parent: f3, internal_name: "f32", data_type: "boolean") }

    it 'should be set automatically' do
      expect(f1.position).to eq 0
      expect(f2.position).to eq 1
      expect(f3.position).to eq 2
      expect(f31.position).to eq 0
      expect(f32.position).to eq 1
    end
  end

  describe "number", clean_with_truncation: true do
    let!(:set) { create(:loan_question_set) }
    let!(:lqroot) { set.root_group }
    let!(:f1) { create(:loan_question, loan_question_set: set, parent: lqroot, internal_name: "f1", data_type: "text") }
    let!(:f2) { create(:loan_question, loan_question_set: set, parent: lqroot, internal_name: "f2", data_type: "text", status: "inactive") }
    let!(:f3) { create(:loan_question, loan_question_set: set, parent: lqroot, internal_name: "f3", data_type: "group") }
    let!(:f31) { create(:loan_question, loan_question_set: set, parent: f3, internal_name: "f31", data_type: "string") }
    let!(:f32) { create(:loan_question, loan_question_set: set, parent: f3, internal_name: "f32", data_type: "boolean") }
    let!(:f4) { create(:loan_question, loan_question_set: set, parent: lqroot, internal_name: "f4", data_type: "text") }

    context "on create" do
      it "sets the correct numbers" do
        expect(f1.reload.number).to eq 1
        expect(f2.reload.number).to be_nil
        expect(f3.reload.number).to eq 2
        expect(f31.reload.number).to eq 1
        expect(f32.reload.number).to eq 2
        expect(f4.reload.number).to eq 3
      end

      context "on move top-level node" do
        before do
          f2.prepend_sibling(f4)
        end

        it "should adjust numbers appropriately" do
          expect(f1.reload.number).to eq 1
          expect(f2.reload.number).to be_nil
          expect(f3.reload.number).to eq 3
          expect(f31.reload.number).to eq 1
          expect(f32.reload.number).to eq 2
          expect(f4.reload.number).to eq 2
        end
      end

      context "on move child node" do
        before do
          f31.prepend_sibling(f32)
        end

        it "should adjust numbers appropriately" do
          expect(f1.reload.number).to eq 1
          expect(f2.reload.number).to be_nil
          expect(f3.reload.number).to eq 2
          expect(f31.reload.number).to eq 2
          expect(f32.reload.number).to eq 1
          expect(f4.reload.number).to eq 3
        end
      end

      context "on change active status" do
        before do
          f2.update_attributes!(status: "active")
        end

        it "should adjust numbers appropriately" do
          expect(f1.reload.number).to eq 1
          expect(f2.reload.number).to eq 2
          expect(f3.reload.number).to eq 3
          expect(f31.reload.number).to eq 1
          expect(f32.reload.number).to eq 2
          expect(f4.reload.number).to eq 4
        end
      end

      context "on destroy" do
        before do
          f1.destroy
        end

        it "should adjust numbers appropriately" do
          expect(f2.reload.number).to be_nil
          expect(f3.reload.number).to eq 1
          expect(f31.reload.number).to eq 1
          expect(f32.reload.number).to eq 2
          expect(f4.reload.number).to eq 2
        end
      end
    end
  end

  describe "full_number", clean_with_truncation: true do
    let!(:set) { create(:loan_question_set) }
    let!(:lqroot) { set.root_group }
    let!(:f1) { create(:loan_question, loan_question_set: set, parent: lqroot, internal_name: "f1", data_type: "text") }
    let!(:f2) { create(:loan_question, loan_question_set: set, parent: lqroot, internal_name: "f2", data_type: "text", status: "inactive") }
    let!(:f3) { create(:loan_question, loan_question_set: set, parent: lqroot, internal_name: "f3", data_type: "group") }
    let!(:f31) { create(:loan_question, loan_question_set: set, parent: f3, internal_name: "f31", data_type: "string", status: "inactive") }
    let!(:f32) { create(:loan_question, loan_question_set: set, parent: f3, internal_name: "f32", data_type: "boolean") }
    let!(:f33) { create(:loan_question, loan_question_set: set, parent: f3, internal_name: "f33", data_type: "group") }
    let!(:f331) { create(:loan_question, loan_question_set: set, parent: f33, internal_name: "f331", data_type: "boolean") }
    let!(:f4) { create(:loan_question, loan_question_set: set, parent: lqroot, internal_name: "f4", data_type: "text") }

    it "should be correct for all nodes" do
      expect(f1.reload.full_number).to eq "1"
      expect(f2.reload.full_number).to be_nil
      expect(f3.reload.full_number).to eq "2"
      expect(f31.reload.full_number).to be_nil
      expect(f32.reload.full_number).to eq "2.1"
      expect(f33.reload.full_number).to eq "2.2"
      expect(f331.reload.full_number).to eq "2.2.1"
      expect(f4.reload.full_number).to eq "3"
    end
  end
end
