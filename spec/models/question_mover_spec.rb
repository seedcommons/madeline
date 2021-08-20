require "rails_helper"

describe QuestionMover do
  # Used by create_question function
  let!(:qset) { create(:question_set, internal_name: "loan_criteria") }

  let!(:div_a) { create(:division, parent: root_division) }
  let!(:div_b) { create(:division, parent: div_a) }
  let!(:div_c1) { create(:division, parent: div_b) }
  let!(:div_c2) { create(:division, parent: div_b) }
  let!(:div_c3) { create(:division, parent: div_b) }
  let!(:div_d) { create(:division, parent: div_c1) }

  # rubocop:disable Layout/IndentationConsistency
  let!(:q0) { create_question(division: div_a, parent: qset.root_group, type: "group") }
    let!(:q00) { create_question(division: div_a, parent: q0, type: "string") }
    let!(:q01) { create_question(division: div_a, parent: q0, type: "string") }
    let!(:q02) { create_question(division: div_b, parent: q0, type: "string") }
    let!(:q03) { create_question(division: div_c1, parent: q0, type: "string") }
  let!(:q1) { create_question(division: div_a, parent: qset.root_group, type: "group") }
    let!(:q10) { create_question(division: div_a, parent: q1, type: "group") }
      let!(:q100) { create_question(division: div_a, parent: q10, type: "string") }
      let!(:q101) { create_question(division: div_a, parent: q10, type: "string") }
      let!(:q102) { create_question(division: div_c2, parent: q10, type: "string") }
      let!(:q103) { create_question(division: div_c2, parent: q10, type: "string") }
    let!(:q11) { create_question(division: div_b, parent: q1, type: "group") }
      let!(:q110) { create_question(division: div_b, parent: q11, type: "string") }
      let!(:q111) { create_question(division: div_c2, parent: q11, type: "string") }
      let!(:q112) { create_question(division: div_c2, parent: q11, type: "string") }
      let!(:q113) { create_question(division: div_c1, parent: q11, type: "string") }
      let!(:q114) { create_question(division: div_c1, parent: q11, type: "string") }
      let!(:q115) { create_question(division: div_c1, parent: q11, type: "string") }
      let!(:q116) { create_question(division: div_c3, parent: q11, type: "string") }
      let!(:q117) { create_question(division: div_c3, parent: q11, type: "string") }
      let!(:q118) { create_question(division: div_d, parent: q11, type: "string") }
      let!(:q119) { create_question(division: div_d, parent: q11, type: "string") }
  let!(:q2) { create_question(division: div_a, parent: qset.root_group, type: "string") }
  let!(:q3) { create_question(division: div_b, parent: qset.root_group, type: "string") }
  let!(:q4) { create_question(division: div_b, parent: qset.root_group, type: "group") }
    let!(:q40) { create_question(division: div_b, parent: q4, type: "string") }
    let!(:q41) { create_question(division: div_c1, parent: q4, type: "string") }
  let!(:q5) { create_question(division: div_c1, parent: qset.root_group, type: "string") }
  let!(:q6) { create_question(division: div_c1, parent: qset.root_group, type: "group") }
    let!(:q60) { create_question(division: div_c1, parent: q6, type: "string") }
    let!(:q61) { create_question(division: div_c1, parent: q6, type: "string") }
    let!(:q62) { create_question(division: div_c3, parent: q6, type: "string") }
  let!(:q7) { create_question(division: div_c1, parent: qset.root_group, type: "group") }
  # rubocop:enable Layout/IndentationConsistency

  subject(:mover) do
    QuestionMover.new(current_division: current_division, question: question,
                      target: target, relation: relation)
  end

  shared_examples_for "succeeds" do
    it "allows and performs correctly" do
      expect { mover.move }.not_to raise_error
      question.reload
      target.reload
      expect(question.parent.data_type).to eq("group")

      case relation
      when :before
        expect(question.parent).to eq(target.parent)
        expect(question.position).to eq(target.position - 1)
      when :after
        expect(question.parent).to eq(target.parent)
        expect(question.position).to eq(target.position + 1)
      when :inside
        expect(question.parent).to eq(target)
        expect(question.position).to eq(0)
      else
        raise "Invalid relation"
      end
    end
  end

  shared_examples_for "denies" do
    it "denies with exception" do
      expect { mover.move }.to raise_error(ArgumentError)
    end
  end

  context "moving question with current division" do
    context "within same parent" do
      context "to top of division block" do
        let(:current_division) { div_c1 }
        let(:question) { q114 }
        let(:target) { q113 }
        let(:relation) { :before }
        it_behaves_like "succeeds"
      end

      context "to bottom of division block" do
        let(:current_division) { div_c1 }
        let(:question) { q113 }
        let(:target) { q115 }
        let(:relation) { :after }
        it_behaves_like "succeeds"
      end

      context "outside of division block" do
        let(:current_division) { div_c1 }
        let(:question) { q113 }
        let(:target) { q116 }
        let(:relation) { :after }
        let(:error) { "must be adjacent to questions of same division" }
        it_behaves_like "denies"
      end
    end

    context "to different parent" do
      context "to non-group" do
        let(:current_division) { div_c1 }
        let(:question) { q113 }
        let(:target) { q114 }
        let(:relation) { :inside }
        let(:error) { "parent must be group" }
        it_behaves_like "denies"
      end

      context "to parent with lower division" do
        let(:current_division) { div_a }
        let(:question) { q2 }
        let(:target) { q4 }
        let(:relation) { :inside }
        let(:error) { "must have parent of same or ancestor division" }
        it_behaves_like "denies"
      end

      context "to parent with ancestor division" do
        context "when existing division block exists" do
          context "within existing division block :after target with same division" do
            let(:current_division) { div_c1 }
            let(:question) { q41 }
            let(:target) { q113 }
            let(:relation) { :after }
            it_behaves_like "succeeds"
          end

          context "within existing division block :after target with different division" do
            let(:current_division) { div_c1 }
            let(:question) { q41 }
            let(:target) { q112 } # has div_c3
            let(:relation) { :after }
            it_behaves_like "succeeds"
          end

          context "within existing division block :before target with different division" do
            let(:current_division) { div_c1 }
            let(:question) { q41 }
            let(:target) { q116 } # has div_c3
            let(:relation) { :before }
            it_behaves_like "succeeds"
          end

          context "within existing division block with :inside" do
            let(:current_division) { div_c1 }
            let(:question) { q115 }
            let(:target) { q6 }
            let(:relation) { :inside }
            it_behaves_like "succeeds"
          end

          context "outside existing division block with :before" do
            let(:current_division) { div_c1 }
            let(:question) { q41 }
            let(:target) { q112 }
            let(:relation) { :before }
            let(:error) { "must be adjacent to questions of same division" }
            it_behaves_like "denies"
          end

          context "outside existing division block with :before at start of siblings" do
            let(:current_division) { div_c1 }
            let(:question) { q41 }
            let(:target) { q110 }
            let(:relation) { :before }
            let(:error) { "must be adjacent to questions of same division" }
            it_behaves_like "denies"
          end

          context "outside existing division block with :after" do
            let(:current_division) { div_c1 }
            let(:question) { q41 }
            let(:target) { q116 }
            let(:relation) { :after }
            let(:error) { "must be adjacent to questions of same division" }
            it_behaves_like "denies"
          end

          context "outside existing division block with :after at end of siblings" do
            let(:current_division) { div_c1 }
            let(:question) { q41 }
            let(:target) { q119 }
            let(:relation) { :after }
            let(:error) { "must be adjacent to questions of same division" }
            it_behaves_like "denies"
          end

          context "outside existing division block with :inside" do
            let(:current_division) { div_c1 }
            let(:question) { q115 }
            let(:target) { q4 }
            let(:relation) { :inside }
            let(:error) { "must be adjacent to questions of same division" }
            it_behaves_like "denies"
          end
        end

        context "when no questions of same division but some of same division depth" do
          context "within existing division depth block adjacent to other division blocks" do
            let(:current_division) { div_c1 }
            let(:question) { q41 }
            let(:target) { q103 }
            let(:relation) { :after }
            it_behaves_like "succeeds"
          end

          context "within existing division depth block inside other division block" do
            let(:current_division) { div_c1 }
            let(:question) { q41 }
            let(:target) { q102 }
            let(:relation) { :after }
            it_behaves_like "succeeds"
          end

          context "outside existing division depth block with :inside" do
            let(:current_division) { div_c1 }
            let(:question) { q41 }
            let(:target) { q10 }
            let(:relation) { :inside }
            let(:error) { "must be after questions of ancestor divisions" }
            it_behaves_like "denies"
          end

          context "outside existing division depth block with :before" do
            let(:current_division) { div_c1 }
            let(:question) { q41 }
            let(:target) { q100 }
            let(:relation) { :before }
            let(:error) { "must be after questions of ancestor divisions" }
            it_behaves_like "denies"
          end
        end

        context "when no questions of same division depth" do
          context "at end of group" do
            let(:current_division) { div_d }
            let(:question) { q118 }
            let(:target) { q11 }
            let(:relation) { :after }
            it_behaves_like "succeeds"
          end

          context "not at end of group" do
            let(:current_division) { div_d }
            let(:question) { q118 }
            let(:target) { q11 }
            let(:relation) { :before }
            let(:error) { "must be after questions of ancestor divisions" }
            it_behaves_like "denies"
          end
        end

        context "when group is empty" do
          context "at end of group" do
            let(:current_division) { div_d }
            let(:question) { q118 }
            let(:target) { q7 }
            let(:relation) { :inside }
            it_behaves_like "succeeds"
          end
        end
      end
    end
  end

  context "moving question with ancestor division than current division" do
    let(:current_division) { div_d }
    let(:question) { q114 }
    let(:target) { q113 }
    let(:relation) { :before }
    let(:error) { "must be in current division" }
    it_behaves_like "denies"
  end

  context "moving question with lower division than current division" do
    let(:current_division) { div_a }
    let(:question) { q114 }
    let(:target) { q113 }
    let(:relation) { :before }
    let(:error) { "must be in current division" }
    it_behaves_like "denies"
  end
end
