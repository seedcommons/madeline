require 'rails_helper'

describe "LoanFilteredQuestion.progress" do
  include_context "question set"

  context "with full question set and responses" do
    include_context "full question set and responses"

    let!(:lfq_root) { LoanFilteredQuestion.new(qset.root_group_preloaded, loan: rset_1.loan, response_set: rset_1) }
    let!(:lookup_table) { lookup_table_for(lfq_root) }

    it "should be correct for a required group" do
      # For required group, we want percentage of all required questions answered.
      # Group has 6 active questions, 3 required, and 2 of those have answers, so 2/3 == 66%
      lfq = lookup_table[q3.id]
      expect(lfq.send(:progress_numerator)).to eq 2
      expect(lfq.send(:progress_denominator)).to eq 3
      expect(lfq.progress_pct).to be_within(0.001).of(0.666)
    end

    it "should be correct for required group with with no required questions" do
      lfq = lookup_table[q33.id]
      expect(lfq.send(:progress_numerator)).to eq 0
      expect(lfq.send(:progress_denominator)).to eq 0
      expect(lfq.progress).to eq 0
    end

    it "should be correct for an optional group" do
      # For optional group, we want percentage of all questions answered, required or not.
      # Group has 4 total questions, and 1 of those has an answer, so 1/4 == 25%
      lfq = lookup_table[q4.id]
      expect(lfq.send(:progress_numerator)).to eq 1
      expect(lfq.send(:progress_denominator)).to eq 4
      expect(lfq.progress).to be_within(0.001).of(0.25)
    end

    it "should exclude inactive questions from calculations" do
      # Inactive questions only show when they are answered, and they are never required, so
      # progress makes no sense.
      lfq = lookup_table[q5.id]
      expect(lfq.send(:progress_numerator)).to eq 0
      expect(lfq.send(:progress_denominator)).to eq 0
      expect(lfq.progress).to eq 0
    end

    it "should be correct for the full custom value set" do
      # Direct children contribute 0/1, group q3 contributes 2/3, total = 2/4 = 50%
      # Optional and inactive groups and questions should be ignored
      expect(lfq_root.send(:progress_numerator)).to eq 2
      expect(lfq_root.send(:progress_denominator)).to eq 4
      expect(lfq_root.progress_pct).to be_within(0.001).of(0.5)
    end
  end


  context "with question with children" do


    let!(:q1) { create_question(parent: root, name: "q1", type: "text", required: false) } # answered
    let!(:q2) { create_question(parent: root, name: "q2", type: "number", required: true) }

    # Question with children
    let!(:q3) { create_question(parent: root, name: "q3", type: "group", required: true) } # answered
      let!(:q31) { create_question(parent: q3, name: "q31", type: "text", required: true) } # answered
      let!(:q32) { create_question(parent: q3, name: "q32", type: "boolean", required: false) } # answered
      let!(:q33) { create_question(parent: q3, name: "q33", type: "text", required: true) } # answered

    before do
      create(:answer,response_set: rset_1, question: q1, text_data: "foo")
      create(:answer,response_set: rset_1, question: q2, text_data: "") # required
      create(:answer,response_set: rset_1, question: q31, text_data: "junk") # required
      create(:answer,response_set: rset_1, question: q32, boolean_data: false)
      create(:answer,response_set: rset_1, question: q33, text_data: "stuff") # required

    end

    it "should be correct" do
      # Top level (required) contributes 1 (answered & required) to numerator and 2 (required) to denominator
      # q3 children contribute 1 (answered & required) to numerator and 1 (required) to denominator
      # Total is 2/3
      lfq_root = LoanFilteredQuestion.new(qset.root_group_preloaded, loan: rset_1.loan, response_set: rset_1)
      lookup_table = lookup_table_for(lfq_root)
      expect(lfq_root.send(:progress_numerator)).to eq 2
      expect(lfq_root.send(:progress_denominator)).to eq 3
      expect(lfq_root.progress_pct).to be_within(0.001).of(0.666)
    end
  end

  context "with empty question set" do
    let!(:lfq_root) { LoanFilteredQuestion.new(qset.root_group_preloaded, loan: rset_1.loan, response_set: rset_1) }
    let!(:lookup_table) { lookup_table_for(lfq_root) }
    it "should be correct" do
      expect(lfq_root.send(:progress_numerator)).to eq 0
      expect(lfq_root.send(:progress_denominator)).to eq 0
      expect(lfq_root.progress_pct).to eq 0
    end
  end
end
