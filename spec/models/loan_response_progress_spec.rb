require 'rails_helper'

describe "LoanResponse.progress" do
  let!(:loan_type_set) { create(:option_set, model_type: ::Loan.name, model_attribute: 'loan_type') }
  let!(:fun_loan_type) { create(:option, option_set: loan_type_set, value: 'fun') }
  let!(:loan) { create(:loan, loan_type_value: "fun")}
  let!(:qset) { create(:loan_question_set, internal_name: 'loan_criteria') }
  let!(:root) { qset.root_group }
  let(:rset) { LoanResponseSet.new(loan: loan, kind: 'criteria') }

  context "with full QuestionSet" do
    let!(:f1) { create_question(parent: root, name: "f1", data_type: "text", required: false) } # answered
    let!(:f2) { create_question(parent: root, name: "f2", data_type: "number", required: true) }

    # Required group with subgroups
    let!(:f3) { create_group(parent: root, name: "f3", required: true) }
      let!(:f31) { create_question(parent: f3, name: "f31", data_type: "string", required: true) } # answered
      let!(:f32) { create_question(parent: f3, name: "f32", data_type: "boolean", required: true) } # answered
      let!(:f33) { create_group(parent: f3, name: "f33", required: true) }
        let!(:f331) { create_question(parent: f33, name: "f331", data_type: "boolean", required: false) } # answered
      let!(:f34) { create_question(parent: f3, name: "f34", data_type: "string", required: false) }
      let!(:f35) { create_question(parent: f3, name: "f35", data_type: "string", required: true) }
      let!(:f36) { create_question(parent: f3, name: "f36", data_type: "string", required: true, status: 'inactive') }
      let!(:f37) { create_question(parent: f3, name: "f37", data_type: "string", required: true, status: 'retired') } # answered
      let!(:f38) { create_group(parent: f3, name: "f38", required: false) }
        let!(:f381) { create_question(parent: f38, name: "f381", data_type: "boolean", required: true) }

    # Optional group
    let!(:f4) { create_group(parent: root, name: "f4", required: false) }
      let!(:f41) { create_question(parent: f4, name: "f41", data_type: "string", required: false) }
      let!(:f42) { create_question(parent: f4, name: "f42", data_type: "boolean", required: false) } # answered
      let!(:f43) { create_question(parent: f4, name: "f43", data_type: "string", required: true) }

    # Inactive group
    let!(:f5) { create_group(parent: root, name: "f5", required: true, status: 'inactive') }
      let!(:f51) { create_question(parent: f5, name: "f51", data_type: "string", required: true) } # answered
      let!(:f52) { create_question(parent: f5, name: "f52", data_type: "boolean", required: false) }

    # Retired group
    let!(:f6) { create_group(parent: root, name: "f6", required: true, status: 'retired') }
      let!(:f61) { create_question(parent: f6, name: "f61", data_type: "string", required: false) } # answered
      let!(:f62) { create_question(parent: f6, name: "f62", data_type: "boolean", required: true, status: 'inactive') }

    before do
      rset.set_response("f1", {"text" => "foo"})
      rset.set_response("f2", {"text" => ""}) # required
      rset.set_response("f31", {"text" => "junk"}) # required
      rset.set_response("f32", {"boolean" => "no"}) # required
      rset.set_response("f331", {"boolean" => "yes"})
      rset.set_response("f37", {"text" => "retired question"})
      rset.set_response("f41", {"text" => ""})
      rset.set_response("f42", {"text" => "pants"}) # required
      rset.set_response("f43", {"text" => ""})
      rset.set_response("f51", {"text" => "inactive group"})
      rset.set_response("f61", {"text" => "retired group"})
    end

    it "should be correct for a required group" do
      # For required group, we want percentage of all required questions answered.
      # Group has 6 active questions, 3 required, and 2 of those have answers, so 2/3 == 66%
      resp = rset.response("f3")
      expect(resp.progress_numerator).to eq 2
      expect(resp.progress_denominator).to eq 3
      expect(resp.progress).to be_within(0.001).of(0.666)
    end

    it "should be correct for required group with with no required questions" do
      resp = rset.response("f33")
      expect(resp.progress_numerator).to eq 0
      expect(resp.progress_denominator).to eq 0
      expect(resp.progress).to eq 0
    end

    it "should be correct for an optional group" do
      # For optional group, we want percentage of all questions answered, required or not.
      # Group has 3 total questions, and 1 of those has an answer, so 1/3 == 33%
      resp = rset.response("f4")
      expect(resp.progress_numerator).to eq 1
      expect(resp.progress_denominator).to eq 3
      expect(resp.progress).to be_within(0.001).of(0.333)
    end

    it "should exclude inactive and retired questions from calculations" do
      # Inactive questions only show when they are answered, and they are never required, so
      # progress makes no sense. Retired questions should never show, so they should be excluded as
      # well.
      resp = rset.response("f5")
      expect(resp.progress_numerator).to eq 0
      expect(resp.progress_denominator).to eq 0
      expect(resp.progress).to eq 0

      resp = rset.response("f6")
      expect(resp.progress_numerator).to eq 0
      expect(resp.progress_denominator).to eq 0
      expect(resp.progress).to eq 0
    end

    it "should be correct for the full custom value set" do
      # Direct children contribute 0/1, group f3 contributes 2/3, total = 2/4 = 50%
      # Optional, inactive and retired groups and questions should be ignored
      expect(rset.progress_numerator).to eq 2
      expect(rset.progress_denominator).to eq 4
      expect(rset.progress).to be_within(0.001).of(0.5)
    end
  end

  context "with question with children" do
    let!(:f1) { create_question(parent: root, name: "f1", data_type: "text", required: false) } # answered
    let!(:f2) { create_question(parent: root, name: "f2", data_type: "number", required: true) }

    # Question with children
    let!(:f3) { create_question(parent: root, name: "f3", data_type: "string", required: true) } # answered
      let!(:f31) { create_question(parent: f3, name: "f31", data_type: "string", required: true) } # answered
      let!(:f32) { create_question(parent: f3, name: "f32", data_type: "boolean", required: false) } # answered

    before do
      rset.set_response("f1", {"text" => "foo"})
      rset.set_response("f2", {"text" => ""}) # required
      rset.set_response("f3", {"text" => "stuff"}) # required
      rset.set_response("f31", {"text" => "junk"}) # required
      rset.set_response("f32", {"boolean" => "no"})
    end

    it "should be correct" do
      # Top level (required) contributes 1 (answered & required) to numerator and 2 (required) to denominator
      # f3 children contribute 1 (answered & required) to numerator and 1 (required) to denominator
      # Total is 2/3
      expect(rset.progress_numerator).to eq 2
      expect(rset.progress_denominator).to eq 3
      expect(rset.progress).to be_within(0.001).of(0.666)
    end
  end

  context "with empty QuestionSet" do
    it "should be correct" do
      expect(rset.progress_numerator).to eq 0
      expect(rset.progress_denominator).to eq 0
      expect(rset.progress).to eq 0
    end
  end

  def create_group(parent: nil, name: "", required:, status: 'active')
    create_question(
      parent: parent,
      name: name,
      data_type: "group",
      required: required,
      status: status,
    )
  end

  def create_question(parent: nil, name:, data_type:, required:, status: 'active')
    field = create(:question,
      loan_question_set: qset,
      parent: parent,
      internal_name: name,
      data_type: data_type,
      override_associations: true,
      status: status,

      # If we want the field to be required we need to set it up to require answers for our loan's loan type.
      loan_types: required ? [fun_loan_type] : []
    )
  end
end
