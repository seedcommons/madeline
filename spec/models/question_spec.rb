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
    let!(:f31) { create_question(set: set, parent: f3, name: "f31", type: "text") }
    let!(:f32) { create_question(set: set, parent: f3, name: "f32", type: "boolean") }

    it "should be set automatically" do
      expect(f1.position).to eq 0
      expect(f2.position).to eq 1
      expect(f3.position).to eq 2
      expect(f31.position).to eq 0
      expect(f32.position).to eq 1
    end

    context "with manually set position" do
      let!(:f33) { create_question(set: set, parent: f3, name: "f33", type: "text", position: 0) }

      it "goes to end anyway (closure_tree does not appear to respect explicit position, not sure why)" do
        expect(f33.reload.position).to eq(2)
      end
    end

    context "when questions from different divisions are present" do
      let!(:div_a1) { create(:division, parent: root_division, name: "a1") }
      let!(:div_b) { create(:division, parent: div_a1, name: "b") }
      let!(:div_a2) { create(:division, parent: root_division, name: "a2") }

      context "when no questions from same division depth are present" do
        let!(:f33) { create_question(set: set, division: div_b, parent: f3, name: "f33", type: "text") }
        let!(:newq) { create_question(set: set, division: div_a1, parent: f3, name: "newq", type: "text") }

        it "goes before question of descendant division" do
          expect_hierarchies(newq) # This was failing if we used after_create instead of after_create_commit
          expect(newq.reload.position).to eq 2
          expect(f33.reload.position).to eq 3
        end
      end

      context "when questions from same division depth are present but not from same division" do
        let!(:f33) { create_question(set: set, division: div_a2, parent: f3, name: "f33", type: "text") }
        let!(:f34) { create_question(set: set, division: div_b, parent: f3, name: "f34", type: "text") }
        let!(:newq) { create_question(set: set, division: div_a1, parent: f3, name: "newq", type: "text") }

        it "goes after question of same depth division" do
          expect(f33.reload.position).to eq 2
          expect(newq.reload.position).to eq 3
          expect(f34.reload.position).to eq 4
        end
      end

      context "when questions from same division are present" do
        let!(:f33) { create_question(set: set, division: div_a1, parent: f3, name: "f33", type: "text") }
        let!(:f34) { create_question(set: set, division: div_a2, parent: f3, name: "f34", type: "text") }
        let!(:f35) { create_question(set: set, division: div_b, parent: f3, name: "f35", type: "text") }
        let!(:newq) { create_question(set: set, division: div_a1, parent: f3, name: "newq", type: "text") }

        it "goes after question of same division" do
          expect(f33.reload.position).to eq 2
          expect(newq.reload.position).to eq 3
          expect(f34.reload.position).to eq 4
          expect(f35.reload.position).to eq 5
        end
      end
    end
  end

  describe "number", clean_with_truncation: true do
    let!(:set) { create(:question_set) }
    let!(:lqroot) { set.root_group }
    let!(:f1) { create_question(set: set, parent: lqroot, name: "f1", type: "text") }
    let!(:f2) { create_question(set: set, parent: lqroot, name: "f2", type: "text", active: false) }
    let!(:f3) { create_question(set: set, parent: lqroot, name: "f3", type: "group") }
    let!(:f31) { create_question(set: set, parent: f3, name: "f31", type: "text") }
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
          f2.update!(active: true)
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
          f1.update!(active: false)
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
    let!(:f2) { create_question(set: set, parent: lqroot, name: "f2", type: "text", active: false) }
    let!(:f3) { create_question(set: set, parent: lqroot, name: "f3", type: "group") }
    let!(:f31) { create_question(set: set, parent: f3, name: "f31", type: "text", active: false) }
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

  describe "validations" do
    describe "group division depth check" do
      let!(:div_a) { create(:division, parent: root_division, name: "div_a") }
      let!(:div_b) { create(:division, parent: div_a, name: "div_b") }
      let!(:div_c) { create(:division, parent: div_b, name: "div_c") }
      let!(:set) { create(:question_set) }
      let!(:group) { create_question(set: set, parent: set.root_group, division: div_b, type: "group") }
      subject(:question) do
        build(:question, question_set: set, data_type: "text", parent: group, division: question_division)
      end

      context "with parent with ancestor division" do
        let(:question_division) { div_c }
        it { is_expected.to be_valid }
      end

      context "with parent with same division" do
        let(:question_division) { div_b }
        it { is_expected.to be_valid }
      end

      context "with parent with descendant division" do
        let(:question_division) { div_a }
        it { is_expected.to have_errors(base: "Parent must be in same or ancestor division") }
      end
    end
  end

  # Checks if there are hierarchies entries pointing to this node
  def expect_hierarchies(question)
    query = "SELECT COUNT(*) FROM question_hierarchies WHERE descendant_id = #{question.id}"
    expect(ApplicationRecord.connection.execute(query).to_a[0]["count"]).to be > 0
  end
end
