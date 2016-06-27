require 'rails_helper'


describe CustomValueSet, :type => :model do

  it 'has a valid factory' do
    expect(create(:custom_value_set)).to be_valid
  end

  it 'can autocreate dynamic attribute' do
    create(:custom_field_set, :loan_criteria)
    expect(create(:loan).loan_criteria(autocreate: true)).to be_kind_of CustomValueSet
  end

  it 'can suppress autocreation' do
    create(:custom_field_set, :loan_criteria)
    expect(create(:loan).loan_criteria).to be_nil
  end

  it 'can get and set custom values' do
    create(:custom_field_set, :loan_criteria)
    loan = create(:loan)
    model = loan.create_loan_criteria
    value = 'this is a summary'
    # model.update_custom_value('summary', value)
    model.summary__text = value
    model.save
    fetched = Loan.find(loan.id).loan_criteria
    # expect(fetched.custom_value('summary')).to eq value
    fetched_summary_obj = fetched.custom_value('summary')
    expect(fetched_summary_obj.class).to eq LoanResponse
    expect(fetched_summary_obj.text).to eq value
  end

end

