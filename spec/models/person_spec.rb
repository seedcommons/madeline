# == Schema Information
#
# Table name: people
#
#  birth_date              :date
#  city                    :string
#  contact_notes           :text
#  country_id              :integer
#  created_at              :datetime         not null
#  division_id             :integer
#  email                   :string
#  fax                     :string
#  first_name              :string
#  has_system_access       :boolean          default(FALSE), not null
#  id                      :integer          not null, primary key
#  last_name               :string
#  legal_name              :string
#  name                    :string
#  neighborhood            :string
#  postal_code             :string
#  primary_organization_id :integer
#  primary_phone           :string
#  secondary_phone         :string
#  state                   :string
#  street_address          :text
#  tax_no                  :string
#  updated_at              :datetime         not null
#  website                 :string
#
# Indexes
#
#  index_people_on_division_id  (division_id)
#
# Foreign Keys
#
#  fk_rails_20168ebb0e  (primary_organization_id => organizations.id)
#  fk_rails_7aab1f72a5  (division_id => divisions.id)
#  fk_rails_fdfb048ae6  (country_id => countries.id)
#

require 'rails_helper'

describe Person, type: :model do


  it 'has a valid factory' do
    expect(create(:person)).to be_valid
  end

  context 'with system access' do
    let(:person) { create(:person, :with_member_access, :with_password) }

    it 'has associated user' do
      expect(person.user).to be_truthy
    end

    it 'is active for authentication' do
      expect(person.user.active_for_authentication?).to eq(true)
    end

    it 'resolves role' do
      expect(person.access_role).to eq(:member)
    end

    it 'mirrors email to user' do
      email = 'test@example.com'
      person.email = email
      person.save
      expect(person.user.email).to eq(email)
    end

    it 'updates role to user' do
      person.access_role = :admin
      person.save
      expect(person.user.roles.first.name).to eq('admin')
    end

  end

end
