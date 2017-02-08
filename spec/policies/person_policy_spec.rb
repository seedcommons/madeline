require 'rails_helper'

describe PersonPolicy do
  context 'person with system access' do
    let(:subject) { create(:person, :with_member_access, :with_password) }

    it 'admin user can edit' do
      user_person = create(:person, :with_admin_access, :with_password)
      expect(PersonPolicy.new(user_person.user, subject).edit?).to be_truthy
    end

    it 'member user cannot edit' do
      user_person = create(:person, :with_member_access, :with_password)
      expect(PersonPolicy.new(user_person.user, subject).edit?).to be_falsy
    end

    it 'can edit self' do
      expect(PersonPolicy.new(subject.user, subject).edit?).to be_truthy
    end
  end

end
