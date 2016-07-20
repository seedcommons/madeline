require 'rails_helper'

describe CustomField, :type => :model do

  it_should_behave_like 'translatable', ['label']

  it 'has a valid factory' do
    expect(create(:custom_field)).to be_valid
  end

  context 'question groups required by loan type' do

    let!(:loan_type_set) { create(:option_set, division: root_division, model_type: ::Loan.name, model_attribute: 'loan_type') }
    let!(:lt1) { create(:option, option_set: loan_type_set, value: 'lt1', label_translations: {en: 'Loan Type One'}) }
    let!(:lt2) { create(:option, option_set: loan_type_set, value: 'lt2', label_translations: {en: 'Loan Type Two'}) }

    let!(:loan1) { create(:loan, loan_type_value: lt1.value)}
    let!(:loan2) { create(:loan, loan_type_value: lt2.value)}

    let!(:set) { create(:custom_field_set) }
    let!(:f1) { create(:custom_field, custom_field_set: set, internal_name: "f1", data_type: "text") }

    let!(:f2) { create(:custom_field, custom_field_set: set, internal_name: "f4", data_type: "text",
      override_associations: true, loan_types: [lt1,lt2]) }

    let!(:f3) { create(:custom_field, custom_field_set: set, internal_name: "f3", data_type: "group",
      override_associations: true, loan_types: [lt1]) }
    let!(:f31) { create(:custom_field, custom_field_set: set, parent: f3, internal_name: "f31", data_type: "string") }
    let!(:f33) { create(:custom_field, custom_field_set: set, parent: f3, internal_name: "f33", data_type: "group") }
    let!(:f331) { create(:custom_field, custom_field_set: set, parent: f33, internal_name: "f331", data_type: "boolean") }
    let!(:f332) { create(:custom_field, custom_field_set: set, parent: f33, internal_name: "f332", data_type: "number",
      override_associations: true, loan_types: [lt2]) }
    let!(:f333) { create(:custom_field, custom_field_set: set, parent: f33, internal_name: "f333", data_type: "text",
      override_associations: true) }

    let!(:f4) { create(:custom_field, custom_field_set: set, internal_name: "f4", data_type: "text",
      loan_types: [lt1,lt2]) }

    it 'not required by default' do
      expect(f1.required_for?(loan1)).to be_falsey
    end

    it 'required when override true and assocation present' do
      expect(f3.required_for?(loan1)).to be_truthy
    end

    it 'not required when override true and assocation not present' do
      expect(f3.required_for?(loan2)).to be_falsey
    end

    it 'required when inherited and parent association present' do
      expect(f31.required_for?(loan1)).to be_truthy
    end

    it 'not required when inherited and parent association not present' do
      expect(f31.required_for?(loan2)).to be_falsey
    end

    it 'not required when override true for child and not present at child level' do
      expect(f332.required_for?(loan1)).to be_falsey
    end

    it 'required when override true for child and present at child level' do
      expect(f332.required_for?(loan2)).to be_truthy
    end

    it 'required when override true and association present for both types' do
      expect(f2.required_for?(loan2)).to be_truthy
    end


    it 'not required when override true for child and no associations present' do
      expect(f333.required_for?(loan1)).to be_falsey
    end

    it 'not required when override false even when association is present' do
      expect(f4.required_for?(loan1)).to be_falsey
    end

  end

end
