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

  describe 'name' do
    let(:organization) { create(:organization, name: " test ") }
    it 'strips white space from name' do
      expect(organization.reload.name).to eq "test"
    end
  end

  describe "geography" do
    let!(:country_us) { create(:country, iso_code: 'US') }
    let!(:country_not_us) { create(:country, iso_code: 'AR') }

    describe "country" do
      it "should be required" do
        org = build(:organization, country: nil)
        expect(org).to be_invalid
      end
    end

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

    context 'entity_structure' do
      it 'cannot be nil' do
        expect {
          create(:organization, entity_structure: nil)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'cannot be blank' do
        expect {
          create(:organization, entity_structure: "")
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'cannot be a typo' do
        expect {
          create(:organization, entity_structure: "non profit")
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'defaults to llc' do
        expect(create(:organization).entity_structure).to eq "llc"
      end

      it 'can be a value in ENTITY_STRUCTURE_OPTIONS' do
        expect {
          create(:organization, entity_structure: "tribal")
        }.not_to raise_error
      end
    end
  end
end
