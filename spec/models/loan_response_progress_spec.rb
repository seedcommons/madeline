require 'rails_helper'

describe "LoanResponse.progress" do
  let(:set) { create(:custom_field_set) }
  let(:vals) { CustomValueSet.new(custom_field_set: set) }

  context "with full CustomFieldSet" do
    let!(:f1) { create(:custom_field, custom_field_set: set, internal_name: "f1", data_type: "text", required: false) }
    let!(:f2) { create(:custom_field, custom_field_set: set, internal_name: "f2", data_type: "number", required: true) }

    # Required group with subgroup
    let!(:f3) { create(:custom_field, custom_field_set: set, internal_name: "f3", data_type: "group", required: true) }
    let!(:f31) { create(:custom_field, custom_field_set: set, parent: f3, internal_name: "f31", data_type: "string", required: true) }
    let!(:f32) { create(:custom_field, custom_field_set: set, parent: f3, internal_name: "f32", data_type: "boolean", required: true) }
    let!(:f33) { create(:custom_field, custom_field_set: set, parent: f3, internal_name: "f33", data_type: "group", required: true) }
    let!(:f331) { create(:custom_field, custom_field_set: set, parent: f33, internal_name: "f331", data_type: "boolean", required: false) }
    let!(:f34) { create(:custom_field, custom_field_set: set, parent: f3, internal_name: "f34", data_type: "string", required: false) }
    let!(:f35) { create(:custom_field, custom_field_set: set, parent: f3, internal_name: "f35", data_type: "string", required: true) }

    # Optional group
    let!(:f4) { create(:custom_field, custom_field_set: set, internal_name: "f4", data_type: "group", required: false) }
    let!(:f41) { create(:custom_field, custom_field_set: set, parent: f4, internal_name: "f41", data_type: "string", required: false) }
    let!(:f42) { create(:custom_field, custom_field_set: set, parent: f4, internal_name: "f42", data_type: "boolean", required: true) }
    let!(:f43) { create(:custom_field, custom_field_set: set, parent: f4, internal_name: "f43", data_type: "string", required: false) }

    before do
      vals.set_custom_value("f1", {"text" => "foo"})
      vals.set_custom_value("f2", {"text" => ""}) # required
      vals.set_custom_value("f31", {"text" => "junk"}) # required
      vals.set_custom_value("f32", {"boolean" => "no"}) # required
      vals.set_custom_value("f331", {"boolean" => "yes"})
      vals.set_custom_value("f41", {"text" => ""})
      vals.set_custom_value("f42", {"text" => "pants"}) # required
      vals.set_custom_value("f43", {"text" => ""})
    end

    it "should be correct for a required group" do
      # For required group, we want percentage of all required questions answered.
      # Group has 5 total questions, 3 required, and 2 of those have answers, so 2/3 == 66%
      expect(vals.custom_value("f3").progress).to be_within(0.001).of(0.666)
    end

    it "should be correct for the full custom value set" do
      # Group f3 contributes 2/3, f4 contributes 1/3, children contribute 1/2, total = 4/8 = 50%
      expect(vals.progress).to be_within(0.001).of(0.5)
    end

    it "should be correct for required group with with no required questions" do
      expect(vals.custom_value("f33").progress).to eq 0
    end

    it "should be correct for an optional group" do
      # For optional group, we want percentage of all questions answered, required or not.
      # Group has 3 total questions, and 1 of those has an answer, so 1/3 == 33%
      expect(vals.custom_value("f4").progress).to be_within(0.001).of(0.333)
    end
  end

  context "with question with children" do
    let!(:f1) { create(:custom_field, custom_field_set: set, internal_name: "f1", data_type: "text", required: false) }
    let!(:f2) { create(:custom_field, custom_field_set: set, internal_name: "f2", data_type: "number", required: true) }

    # Question with children
    let!(:f3) { create(:custom_field, custom_field_set: set, internal_name: "f3", data_type: "string", required: true) }
    let!(:f31) { create(:custom_field, custom_field_set: set, parent: f3, internal_name: "f31", data_type: "string", required: true) }
    let!(:f32) { create(:custom_field, custom_field_set: set, parent: f3, internal_name: "f32", data_type: "boolean", required: false) }

    before do
      vals.set_custom_value("f1", {"text" => "foo"})
      vals.set_custom_value("f2", {"text" => ""}) # required
      vals.set_custom_value("f3", {"text" => "stuff"}) # required
      vals.set_custom_value("f31", {"text" => "junk"}) # required
      vals.set_custom_value("f32", {"boolean" => "no"})
    end


    it "should be correct" do
      # Top level (optional) contributes 2 (answered) to numerator and 3 (total) to denominator
      # f3 children contribute 1 (answered & required) to numerator and 1 (required) to denominator
      # Total is 3/4 = 75%
      expect(vals.progress).to be_within(0.001).of(0.75)
    end
  end

  context "with empty CustomFieldSet" do
    it "should be correct" do
      expect(vals.progress).to eq 0
    end
  end
end
