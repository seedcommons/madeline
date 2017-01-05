require 'rails_helper'

describe NotePolicy do
  subject { described_class.new(user, record) }

  context "division member" do
    let(:division) { create(:division) }
    let(:user) { create(:user, :member, division: division) }
    let(:org) { create(:organization, division: division) }
    let(:record) { create(:note, notable: org) }

    it { should permit_action(:create) }

    context "own note" do
      let(:record) { create(:note, author: user.profile, notable: org) }

      it { should permit_action(:edit) }
      it { should permit_action(:update) }
      it { should permit_action(:destroy) }
    end

  end
end
