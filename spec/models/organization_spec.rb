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
#  qb_id              :string
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
#  fk_rails_...  (country_id => countries.id)
#  fk_rails_...  (division_id => divisions.id)
#  fk_rails_...  (primary_contact_id => people.id)
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

  describe "geography" do
    let!(:country_us) { create(:country, name: 'United States') }
    let!(:country_not_us) { create(:country, name: 'Argentina') }

    describe 'postal_code' do
      it "should be required  for US organizations" do
        org = build(:organization, country: country_us, state: "IN", postal_code: nil)
        expect(org.valid?).to be false
      end

      it "should not be required  for non-US organizations" do
        org = build(:organization, country: country_not_us, postal_code: nil)
        expect(org.valid?).to be true
      end
    end

    describe "state" do
      it "should be required  for US organization" do
        org = build(:organization, country: country_us, state: nil)
        expect(org.valid?).to be false
      end

      it "should not be required  for non-US organizations" do
        org = build(:organization, country: country_not_us, state: nil)
        expect(org.valid?).to be true
      end
    end
  end
end
