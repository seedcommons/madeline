require 'rails_helper'

describe Person, type: :model do
  let(:log) { build(:project_log) }
  let(:person) { create(:person, :with_member_access, :with_password, project_logs: [log]) }
  let!(:note) { create(:note, author: person) }

  it 'has a valid factory' do
    expect(create(:person)).to be_valid
  end

  context 'with system access' do

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

  context 'destroy' do
    before { person.destroy }

    it 'log sets agent_id to nil' do
      person.destroy
      expect(log.reload.agent).to be_nil
    end

    it 'note sets author_id to nil' do
      person.destroy
      expect(note.reload.author).to be_nil
    end
  end
end
