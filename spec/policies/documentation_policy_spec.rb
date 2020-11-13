require 'rails_helper'

describe DocumentationPolicy do
  subject { described_class.new(user, record) }

  let!(:parent_division) { create(:division) }
  let!(:division) { create(:division, parent: parent_division) }
  let!(:child_division) { create(:division, parent: division) }
  let(:user) { create(:user, :member, division: division) }

  context "documentation belongs to user's division" do
    let(:record) { create(:documentation, division: division) }

    it { should permit_all_but_index }
  end

  context "documentation belongs to ancestor of user's division" do
    let(:record) { create(:documentation, division: parent_division) }

    it { should permit_action(:show) }
    it { should forbid_action(:edit) }
  end

  context "documentation belongs to descendant of user's division" do
    let(:record) { create(:documentation, division: child_division) }

    it { should permit_action(:show) }
    it { should permit_action(:edit) }
  end

  context "documentation belongs to a division that is not a descendant or ancestor of any of the user's divisions " do
    let(:other_division) { create(:division) }
    let(:record) { create(:documentation, division: other_division) }
    it { should forbid_action(:show) }
    it { should forbid_action(:edit) }
  end
end
