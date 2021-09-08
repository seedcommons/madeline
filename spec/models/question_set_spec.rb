require "rails_helper"

describe QuestionSet do
  let!(:division) { create(:division) }

  it "has a valid factory" do
    expect(create(:question_set)).to be_valid
  end

  describe ".find_for_division" do
    let!(:div_a) { create(:division) }
    let!(:div_b) { create(:division, parent: div_a) }
    let!(:div_c) { create(:division, parent: div_b) }
    let!(:div_x) { create(:division) }
    let!(:div_a_set1) { create(:question_set, division: div_a, kind: "loan_post_analysis") }
    let!(:div_a_set2) { create(:question_set, division: div_a, kind: "loan_criteria") }
    let!(:div_b_set) { create(:question_set, division: div_b, kind: "loan_criteria") }

    it "finds correct sets for div_a in correct order" do
      expect(QuestionSet.find_for_division(div_a)).to eq([div_a_set2, div_a_set1])
    end

    it "finds correct sets for div_b in correct order" do
      expect(QuestionSet.find_for_division(div_b)).to eq([div_b_set, div_a_set1])
    end

    it "finds correct sets for div_c in correct order" do
      expect(QuestionSet.find_for_division(div_c)).to eq([div_b_set, div_a_set1])
    end

    it "returns empty array if no sets defined" do
      expect(QuestionSet.find_for_division(div_x)).to be_empty
    end
  end
end
