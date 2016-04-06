require 'rails_helper'

describe DivisionPolicy do
  subject { DivisionPolicy.new(user, division) }

  let!(:parent_division) { create(:division) }
  let!(:division) { create(:division, parent: parent_division) }
  let!(:child_division) { create(:division, parent: division) }

  context 'being a member of a division' do
    let(:user) { create(:user, :member, division: division) }

    permit_actions [:index, :show]
    forbid_actions [:create, :edit, :update, :destroy]
  end

  context 'being an admin of a division' do
    let(:user) { create(:user, :admin, division: division) }

    permit_all
  end

  context 'being a member of a parent division' do
    let(:user) { create(:user, :member, division: parent_division) }

    permit_actions [:index, :show]
    forbid_actions [:create, :edit, :update, :destroy]
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
