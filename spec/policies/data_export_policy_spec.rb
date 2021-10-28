require "rails_helper"

describe DataExportPolicy do
  let(:divisionA) { create(:division) }
  let(:divisionB) { create(:division, parent: divisionA) }
  let(:divisionC) { create(:division, parent: divisionB) }
  let(:divisionD) { create(:division) }
  subject { described_class.new(user, record) }

  let(:record) { create(:data_export, division: divisionB) }

  context "user is member of parent division" do
    let(:user) { create_member(divisionA) }
    it { should permit_all }
  end

  context "user is member of same division" do
    let(:user) { create_member(divisionB) }
    it { should permit_all }
  end

  context "user is member of child division" do
    let(:user) { create_member(divisionC) }
    it { should forbid_all }
  end

  context "user is member of unrelated division" do
    let(:user) { create_member(divisionD) }
    it { should forbid_all }
  end
end
