# == Schema Information
#
# Table name: organizations
#
#  alias              :string
#  city               :string
#  contact_notes      :text
#  country_id         :integer
#  created_at         :datetime         not null
#  custom_data        :json
#  division_id        :integer
#  email              :string
#  fax                :string
#  id                 :integer          not null, primary key
#  industry           :string
#  is_recovered       :boolean
#  last_name          :string
#  legal_name         :string
#  name               :string
#  neighborhood       :string
#  postal_code        :string
#  primary_contact_id :integer
#  primary_phone      :string
#  referral_source    :string
#  secondary_phone    :string
#  sector             :string
#  state              :string
#  street_address     :text
#  tax_no             :string
#  updated_at         :datetime         not null
#  website            :string
#
# Indexes
#
#  index_organizations_on_division_id  (division_id)
#
# Foreign Keys
#
#  fk_rails_0de9c8b6c9  (country_id => countries.id)
#  fk_rails_a43f2db6ae  (primary_contact_id => people.id)
#  fk_rails_e5fef62474  (division_id => divisions.id)
#

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
