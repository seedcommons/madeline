require 'rails_helper'

describe Organization, type: :model do
  it 'has a valid factory' do
    expect(create(:organization)).to be_valid
  end

  it_should_behave_like 'notable'

  it 'errors when primary_contact does not belong to organization' do
    contact = create(:person)
    expect{ create(:organization, primary_contact: contact) }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it 'primary_contact can be added when also part of organization' do
    contact = create(:person)
    create(:organization, primary_contact: contact, people: [contact])
  end
end
