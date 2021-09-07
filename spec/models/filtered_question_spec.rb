require "rails_helper"

describe FilteredQuestion, type: :model do
  let(:include_descendant_divisions) { false }

  let!(:d0) { create(:division, name: "Root Division") }
    let!(:d1) { create(:division, name: "First Division", parent: d0) }
      let!(:d11) { create(:division, name: "Child - First Division", parent: d1) }
    let!(:d2) { create(:division, name: "Second Division", parent: d0) }
      let!(:d21) { create(:division, name: "Child - Second Division", parent: d2) }

  let!(:q0) { create(:question, division: d0) }
  let!(:q1) { create(:question, division: d1) }
  let!(:q11) { create(:question, division: d11) }
  let!(:q2) { create(:question, division: d2) }
  let!(:q21) { create(:question, division: d21) }

  describe "#visible?" do
    context "include_descendant_divisions false" do
      it "shows only questions belonging to the selected division and its ancestors" do
        # Root division selected
        expect(filtered_question(q0, d0)).to be_visible
        expect(filtered_question(q1, d0)).not_to be_visible
        expect(filtered_question(q11, d0)).not_to be_visible
        expect(filtered_question(q2, d0)).not_to be_visible
        expect(filtered_question(q21, d0)).not_to be_visible

        # Middle-generation division selected
        expect(filtered_question(q0, d1)).to be_visible
        expect(filtered_question(q1, d1)).to be_visible
        expect(filtered_question(q11, d1)).not_to be_visible
        expect(filtered_question(q2, d1)).not_to be_visible
        expect(filtered_question(q21, d1)).not_to be_visible

        # Leaf division selected
        expect(filtered_question(q0, d11)).to be_visible
        expect(filtered_question(q1, d11)).to be_visible
        expect(filtered_question(q11, d11)).to be_visible
        expect(filtered_question(q2, d11)).not_to be_visible
        expect(filtered_question(q21, d11)).not_to be_visible

        # Middle-generation division selected
        expect(filtered_question(q0, d2)).to be_visible
        expect(filtered_question(q1, d2)).not_to be_visible
        expect(filtered_question(q11, d2)).not_to be_visible
        expect(filtered_question(q2, d2)).to be_visible
        expect(filtered_question(q21, d2)).not_to be_visible

        # Leaf division selected
        expect(filtered_question(q0, d21)).to be_visible
        expect(filtered_question(q1, d21)).not_to be_visible
        expect(filtered_question(q11, d21)).not_to be_visible
        expect(filtered_question(q2, d21)).to be_visible
        expect(filtered_question(q21, d21)).to be_visible
      end
    end

    context "include_descendant_divisions true" do
      let(:include_descendant_divisions) { true }

      it "shows questions belonging to the selected division, its ancestors and its descendants" do
        # Root division selected
        expect(filtered_question(q0, d0)).to be_visible
        expect(filtered_question(q1, d0)).to be_visible
        expect(filtered_question(q11, d0)).to be_visible
        expect(filtered_question(q2, d0)).to be_visible
        expect(filtered_question(q21, d0)).to be_visible

        # Middle-generation division selected
        expect(filtered_question(q0, d1)).to be_visible
        expect(filtered_question(q1, d1)).to be_visible
        expect(filtered_question(q11, d1)).to be_visible
        expect(filtered_question(q2, d1)).not_to be_visible
        expect(filtered_question(q21, d1)).not_to be_visible

        # Leaf division selected
        expect(filtered_question(q0, d11)).to be_visible
        expect(filtered_question(q1, d11)).to be_visible
        expect(filtered_question(q11, d11)).to be_visible
        expect(filtered_question(q2, d11)).not_to be_visible
        expect(filtered_question(q21, d11)).not_to be_visible

        # Middle-generation division selected
        expect(filtered_question(q0, d2)).to be_visible
        expect(filtered_question(q1, d2)).not_to be_visible
        expect(filtered_question(q11, d2)).not_to be_visible
        expect(filtered_question(q2, d2)).to be_visible
        expect(filtered_question(q21, d2)).to be_visible

        # Leaf division selected
        expect(filtered_question(q0, d21)).to be_visible
        expect(filtered_question(q1, d21)).not_to be_visible
        expect(filtered_question(q11, d21)).not_to be_visible
        expect(filtered_question(q2, d21)).to be_visible
        expect(filtered_question(q21, d21)).to be_visible
      end
    end
  end

  describe "#children" do
    let!(:child_q2) { create(:question, parent: q2, division: d2) }
    let!(:child_q21) { create(:question, parent: q2, division: d21) }

    context "include_descendant_divisions false" do
      it "should return only visible children" do
        q2.reload
        expect(filtered_question(q2, d21).children.map(&:question)).to contain_exactly(child_q2, child_q21)
        expect(filtered_question(q2, d2).children.map(&:question)).to contain_exactly(child_q2)
      end
    end

    context "include_descendant_divisions true" do
      let(:include_descendant_divisions) { true }

      it "should pass down include_descendant_divisions flag" do
        q2.reload
        expect(filtered_question(q2, d21).children.map(&:question)).to contain_exactly(child_q2, child_q21)
        expect(filtered_question(q2, d2).children.map(&:question)).to contain_exactly(child_q2, child_q21)
      end
    end
  end

  def filtered_question(question, division)
    FilteredQuestion.new(question, selected_division: division,
                                   include_descendant_divisions: include_descendant_divisions)
  end
end
