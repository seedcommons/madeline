require 'rails_helper'

describe "LoanResponse.progress" do
  include_context "question set"

  context "with full question set and responses" do
    include_context "full question set and responses"

    it "should be correct for a required group" do
      # For required group, we want percentage of all required questions answered.
      # Group has 6 active questions, 3 required, and 2 of those have answers, so 2/3 == 66%
      resp = rset.response("q3")
      expect(resp.progress_numerator).to eq 2
      expect(resp.progress_denominator).to eq 3
      expect(resp.progress).to be_within(0.001).of(0.666)
    end

    it "should be correct for required group with with no required questions" do
      resp = rset.response("q33")
      expect(resp.progress_numerator).to eq 0
      expect(resp.progress_denominator).to eq 0
      expect(resp.progress).to eq 0
    end

    it "should be correct for an optional group" do
      # For optional group, we want percentage of all questions answered, required or not.
      # Group has 3 total questions, and 1 of those has an answer, so 1/3 == 33%
      resp = rset.response("q4")
      expect(resp.progress_numerator).to eq 1
      expect(resp.progress_denominator).to eq 3
      expect(resp.progress).to be_within(0.001).of(0.333)
    end

    it "should exclude inactive and retired questions from calculations" do
      # Inactive questions only show when they are answered, and they are never required, so
      # progress makes no sense. Retired questions should never show, so they should be excluded as
      # well.
      resp = rset.response("q5")
      expect(resp.progress_numerator).to eq 0
      expect(resp.progress_denominator).to eq 0
      expect(resp.progress).to eq 0

      resp = rset.response("q6")
      expect(resp.progress_numerator).to eq 0
      expect(resp.progress_denominator).to eq 0
      expect(resp.progress).to eq 0
    end

    it "should be correct for the full custom value set" do
      # Direct children contribute 0/1, group q3 contributes 2/3, total = 2/4 = 50%
      # Optional, inactive and retired groups and questions should be ignored
      expect(rset.progress_numerator).to eq 2
      expect(rset.progress_denominator).to eq 4
      expect(rset.progress).to be_within(0.001).of(0.5)
    end
  end

  context "with question with children" do
    let!(:q1) { create_question(parent: root, name: "q1", type: "text", required: false) } # answered
    let!(:q2) { create_question(parent: root, name: "q2", type: "number", required: true) }

    # Question with children
    let!(:q3) { create_question(parent: root, name: "q3", type: "string", required: true) } # answered
      let!(:q31) { create_question(parent: q3, name: "q31", type: "string", required: true) } # answered
      let!(:q32) { create_question(parent: q3, name: "q32", type: "boolean", required: false) } # answered

    before do
      rset.set_response("q1", {"text" => "foo"})
      rset.set_response("q2", {"text" => ""}) # required
      rset.set_response("q3", {"text" => "stuff"}) # required
      rset.set_response("q31", {"text" => "junk"}) # required
      rset.set_response("q32", {"boolean" => "no"})
    end

    it "should be correct" do
      # Top level (required) contributes 1 (answered & required) to numerator and 2 (required) to denominator
      # q3 children contribute 1 (answered & required) to numerator and 1 (required) to denominator
      # Total is 2/3
      expect(rset.progress_numerator).to eq 2
      expect(rset.progress_denominator).to eq 3
      expect(rset.progress).to be_within(0.001).of(0.666)
    end
  end

  context "with question set" do
    it "should be correct" do
      expect(rset.progress_numerator).to eq 0
      expect(rset.progress_denominator).to eq 0
      expect(rset.progress).to eq 0
    end
  end
end
