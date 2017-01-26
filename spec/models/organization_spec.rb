require 'rails_helper'

describe Organization, type: :model do
  it 'has a valid factory' do
    expect(create(:organization)).to be_valid
  end

  it_should_behave_like 'notable'

  describe 'primary contact' do
    let(:contact) { create(:person) }

    it 'errors when does not belong to organization' do
      expect { create(:organization, primary_contact: contact) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'can be added when also part of organization' do
      expect { create(:organization, primary_contact: contact, people: [contact]) }.to_not raise_error
    end
  end
end
