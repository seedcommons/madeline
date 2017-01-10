require 'rails_helper'

describe NotePolicy do
  subject { described_class.new(user, record) }

  let(:division) { create(:division) }
  let(:org) { create(:organization, division: division) }
  let(:record) { create(:note, notable: org) }

  context "division member" do
    let(:user) { create(:user, :member, division: division) }

    it { should permit_new_and_create_actions }

    context "other's note" do
      it { should forbid_edit_and_update_actions }
      it { should forbid_action(:destroy) }
    end

    context "own note" do
      let(:record) { create(:note, author: user.profile, notable: org) }

      it { should permit_action(:edit) }
      it { should permit_action(:update) }
      it { should permit_action(:destroy) }
    end
  end

  context "division admin" do
    let(:user) { create(:user, :admin, division: division) }

    it { should permit_action(:create) }

    context "other's note" do
      it { should forbid_edit_and_update_actions }
      it { should permit_action(:destroy) }
    end
  end
end
