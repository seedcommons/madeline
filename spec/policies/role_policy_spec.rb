require 'rails_helper'

describe RolePolicy do
  subject { RolePolicy.new(user, role) }

  let(:parent_division) { create(:division) }
  let(:division) { create(:division, parent: parent_division) }
  let(:child_division) { create(:division, parent: division) }

  let(:role) { build(:role, resource: division) }

  context 'being a member of a division' do
    let(:user) { create(:user, :member, division: division) }

    forbid_all
  end

  context 'being an admin of a division' do
    let(:user) { create(:user, :admin, division: division) }

    permit_all
  end

  context 'being a member of a parent division' do
    let(:user) { create(:user, :member, division: parent_division) }

    forbid_all
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
