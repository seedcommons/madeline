require 'rails_helper'

describe UserPolicy do
  subject { UserPolicy.new(user, described_user) }

  let!(:parent_division) { create(:division) }
  let!(:division) { create(:division, parent: parent_division) }
  let!(:child_division) { create(:division, parent: division) }

  let(:described_user) { create(:user, division: division) }

  context 'being the user' do
    let(:user) { described_user }

    permit_actions [:edit, :update, :show]
    forbid_actions [:index, :create, :destroy]
  end

  context 'being a member of the division' do
    let(:user) { create(:user, :member, division: division) }

    permit_actions [:index, :show]
    forbid_actions [:destroy, :edit, :update, :create]
  end

  context 'being an admin in the division' do
    let(:user) { create(:user, :admin, division: division) }

    permit_all
  end

  context 'being a member of a parent division' do
    let(:user) { create(:user, :member, division: parent_division) }

    permit_actions [:index, :show]
    forbid_actions [:destroy, :create, :edit, :update]
  end

  context 'being an admin of a parent division' do
    let(:user) { create(:user, :admin, division: parent_division) }

    permit_all
  end

  context 'being a member of a child division' do
    let(:user) { create(:user, :member, division: child_division) }

    forbid_all
  end

  context 'being an admin of a child division' do
    let(:user) { create(:user, :admin, division: child_division) }

    forbid_all
  end
end
