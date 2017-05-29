require 'rails_helper'

describe "LoanResponse.progress" do
  let!(:loan_type_set) { create(:option_set, model_type: ::Loan.name, model_attribute: 'loan_type') }
  let!(:fun_loan_type) { create(:option, option_set: loan_type_set, value: 'fun') }
  let!(:loan) { create(:loan, loan_type_value: "fun")}
  let!(:set) { create(:loan_question_set, internal_name: 'loan_criteria') }
  let!(:root) { set.root_group }
  let(:vals) { LoanResponseSet.new(loan: loan, kind: 'criteria') }

  context "with full LoanQuestionSet" do
    let!(:f1) { create_question(parent: root, name: "f1", data_type: "text", required: false) }
    let!(:f2) { create_question(parent: root, name: "f2", data_type: "number", required: true) }

    # Required group with subgroup
    let!(:f3) { create_question(parent: root, name: "f3", data_type: "group", required: true) }
    let!(:f31) { create_question(parent: f3, name: "f31", data_type: "string", required: true) }
    let!(:f32) { create_question(parent: f3, name: "f32", data_type: "boolean", required: true) }
    let!(:f33) { create_question(parent: f3, name: "f33", data_type: "group", required: true) }
    let!(:f331) { create_question(parent: f33, name: "f331", data_type: "boolean", required: false) }
    let!(:f34) { create_question(parent: f3, name: "f34", data_type: "string", required: false) }
    let!(:f35) { create_question(parent: f3, name: "f35", data_type: "string", required: true) }
    let!(:f36) { create_question(parent: f3, name: "f36", data_type: "string", required: true, status: 'inactive') }
    let!(:f37) { create_question(parent: f3, name: "f37", data_type: "string", required: true, status: 'retired') }

    # Optional group
    let!(:f4) { create_question(parent: root, name: "f4", data_type: "group", required: false) }
    let!(:f41) { create_question(parent: f4, name: "f41", data_type: "string", required: false) }
    let!(:f42) { create_question(parent: f4, name: "f42", data_type: "boolean", required: true) }
    let!(:f43) { create_question(parent: f4, name: "f43", data_type: "string", required: false) }

    # Inactive group
    let!(:f5) { create_question(parent: root, name: "f5", data_type: "group", required: false, status: 'inactive') }
    let!(:f51) { create_question(parent: f5, name: "f51", data_type: "string", required: false) }
    let!(:f52) { create_question(parent: f5, name: "f52", data_type: "boolean", required: true) }

    # Retired group
    let!(:f6) { create_question(parent: root, name: "f6", data_type: "group", required: false, status: 'retired') }
    let!(:f61) { create_question(parent: f6, name: "f61", data_type: "string", required: false) }
    let!(:f62) { create_question(parent: f6, name: "f62", data_type: "boolean", required: true, status: 'inactive') }

    before do
      vals.set_response("f1", {"text" => "foo"})
      vals.set_response("f2", {"text" => ""}) # required
      vals.set_response("f31", {"text" => "junk"}) # required
      vals.set_response("f32", {"boolean" => "no"}) # required
      vals.set_response("f331", {"boolean" => "yes"})
      vals.set_response("f37", {"text" => "retired question"})
      vals.set_response("f41", {"text" => ""})
      vals.set_response("f42", {"text" => "pants"}) # required
      vals.set_response("f43", {"text" => ""})
      vals.set_response("f51", {"text" => "inactive group"})
      vals.set_response("f61", {"text" => "retired group"})
    end

    it "should be correct for a required group" do
      # For required group, we want percentage of all required questions answered.
      # Group has 5 active questions, 3 required, and 2 of those have answers, so 2/3 == 66%
      expect(vals.response("f3").progress).to be_within(0.001).of(0.666)
    end

    it "should be correct for the full custom value set" do
      # Group f3 contributes 2/3, f4 contributes 1/3, children contribute 1/2, total = 4/8 = 50%
      expect(vals.progress).to be_within(0.001).of(0.5)
    end

    it "should be correct for required group with with no required questions" do
      expect(vals.response("f33").progress).to eq 0
    end

    it "should be correct for an optional group" do
      # For optional group, we want percentage of all questions answered, required or not.
      # Group has 3 total questions, and 1 of those has an answer, so 1/3 == 33%
      expect(vals.response("f4").progress).to be_within(0.001).of(0.333)
    end

    it "should exclude inactive and retired questions from calculations" do
      # Inactive questions only show when they are answered, and they are never required, so
      # progress makes no sense. Retired questions should never show, so they should be excluded as
      # well.
      expect(vals.response("f5").progress).to eq 0
      expect(vals.response("f6").progress).to eq 0
    end
  end

  context "with question with children" do
    let!(:f1) { create_question(parent: root, name: "f1", data_type: "text", required: false) }
    let!(:f2) { create_question(parent: root, name: "f2", data_type: "number", required: true) }

    # Question with children
    let!(:f3) { create_question(parent: root, name: "f3", data_type: "string", required: true) }
    let!(:f31) { create_question(parent: f3, name: "f31", data_type: "string", required: true) }
    let!(:f32) { create_question(parent: f3, name: "f32", data_type: "boolean", required: false) }

    before do
      vals.set_response("f1", {"text" => "foo"})
      vals.set_response("f2", {"text" => ""}) # required
      vals.set_response("f3", {"text" => "stuff"}) # required
      vals.set_response("f31", {"text" => "junk"}) # required
      vals.set_response("f32", {"boolean" => "no"})
    end

    it "should be correct" do
      # Top level (optional) contributes 2 (answered) to numerator and 3 (total) to denominator
      # f3 children contribute 1 (answered & required) to numerator and 1 (required) to denominator
      # Total is 3/4 = 75%
      expect(vals.progress).to be_within(0.001).of(0.75)
    end
  end

  context "with empty LoanQuestionSet" do
    it "should be correct" do
      expect(vals.progress).to eq 0
    end
  end

  def create_group(parent: nil, name: "")
    create(:loan_question,
      loan_question_set: set,
      parent: parent,
      internal_name: name,
      data_type: "group"
    )
  end

  def create_question(parent: nil, name:, data_type:, required:, status: 'active')
    field = create(:loan_question,
      loan_question_set: set,
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
