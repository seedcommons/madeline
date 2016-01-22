require 'rails_helper'


describe CustomModel, :type => :model do

  it 'has a valid factory' do
    expect(create(:custom_model)).to be_valid
  end

  it 'can autocreate dynamic attribute' do
    create(:custom_field_set, :loan_criteria)
    expect(create(:loan).loan_criteria).to be_kind_of CustomModel
  end

  it 'can suppress autocreation' do
    create(:custom_field_set, :loan_criteria)
    expect(create(:loan).loan_criteria(autocreate:false)).to be_nil
  end

  it 'can get and set custom values' do
    create(:custom_field_set, :loan_criteria)
    loan = create(:loan)
    model = loan.loan_criteria
    value = 'this is a summary'
    model.update_value('summary', value)
    fetched = Loan.find(loan.id).loan_criteria
    expect(fetched.get_value('summary')).to eq value
  end

end

