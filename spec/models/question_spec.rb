require 'rails_helper'

describe Question, :type => :model do
  let!(:division) { create(:division) }

  it 'has a valid factory' do
    expect(create(:question)).to be_valid
  end

  describe 'position' do
    let!(:set) { create(:question_set) }
    let!(:lqroot) { create_question(set: set, name: "lqroot", type: "group") }
    let!(:f1) { create_question(set: set, parent: lqroot, name: "f1", type: "text") }
    let!(:f2) { create_question(set: set, parent: lqroot, name: "f2", type: "text", override_associations: true) }
    let!(:f3) { create_question(set: set, parent: lqroot, name: "f3", type: "group", override_associations: true) }
    let!(:f31) { create_question(set: set, parent: f3, name: "f31", type: "string") }
    let!(:f32) { create_question(set: set, parent: f3, name: "f32", type: "boolean") }

    it 'should be set automatically' do
      expect(f1.position).to eq 0
      expect(f2.position).to eq 1
      expect(f3.position).to eq 2
      expect(f31.position).to eq 0
      expect(f32.position).to eq 1
    end
  end

  describe "number", clean_with_truncation: true do
    let!(:set) { create(:question_set) }
    let!(:lqroot) { set.root_group }
    let!(:f1) { create_question(set: set, parent: lqroot, name: "f1", type: "text") }
    let!(:f2) { create_question(set: set, parent: lqroot, name: "f2", type: "text", status: "inactive") }
    let!(:f3) { create_question(set: set, parent: lqroot, name: "f3", type: "group") }
    let!(:f31) { create_question(set: set, parent: f3, name: "f31", type: "string") }
    let!(:f32) { create_question(set: set, parent: f3, name: "f32", type: "boolean") }
    let!(:f4) { create_question(set: set, parent: lqroot, name: "f4", type: "text") }

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

      context "on activate" do
        before do
          f2.update!(status: "active")
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

      context "on deactivate" do
        before do
          f1.update!(status: "inactive")
        end

        it "should adjust numbers appropriately" do
          expect(f1.number).to be_nil # Fails with `reload` for some reason
          expect(f2.reload.number).to be_nil
          expect(f3.reload.number).to eq 1
          expect(f31.reload.number).to eq 1
          expect(f32.reload.number).to eq 2
          expect(f4.reload.number).to eq 2
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
    let!(:set) { create(:question_set) }
    let!(:lqroot) { set.root_group }
    let!(:f1) { create_question(set: set, parent: lqroot, name: "f1", type: "text") }
    let!(:f2) { create_question(set: set, parent: lqroot, name: "f2", type: "text", status: "inactive") }
    let!(:f3) { create_question(set: set, parent: lqroot, name: "f3", type: "group") }
    let!(:f31) { create_question(set: set, parent: f3, name: "f31", type: "string", status: "inactive") }
    let!(:f32) { create_question(set: set, parent: f3, name: "f32", type: "boolean") }
    let!(:f33) { create_question(set: set, parent: f3, name: "f33", type: "group") }
    let!(:f331) { create_question(set: set, parent: f33, name: "f331", type: "boolean") }
    let!(:f4) { create_question(set: set, parent: lqroot, name: "f4", type: "text") }

    it "should be correct for all nodes" do
      expect(f1.reload.full_number).to eq "I"
      expect(f2.reload.full_number).to be_nil
      expect(f3.reload.full_number).to eq "II"
      expect(f31.reload.full_number).to be_nil
      expect(f32.reload.full_number).to eq "A"
      expect(f33.reload.full_number).to eq "B"
      expect(f331.reload.full_number).to eq "1"
      expect(f4.reload.full_number).to eq "III"
    end
  end
end
