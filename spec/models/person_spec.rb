require 'rails_helper'

describe Person, type: :model do


  it 'has a valid factory' do
    expect(create(:person)).to be_valid
  end

  it_should_behave_like 'notable'

  context 'with system access' do
    let(:person) { create(:person, :with_member_access, :with_password) }

    it 'has associated user' do
      expect(person.user).to be_truthy
    end

    it 'is active for authentication' do
      expect(person.user.active_for_authentication?).to eq(true)
    end

    it 'resolves role' do
      expect(person.owning_division_role).to eq(:member)
    end

    it 'mirrors email to user' do
      email = 'test@example.com'
      person.email = email
      person.save
      expect(person.user.email).to eq(email)
    end

    it 'updates role to user' do
      person.owning_division_role = :admin
      person.save
      expect(person.user.roles.first.name).to eq('admin')
    end

  end

end
