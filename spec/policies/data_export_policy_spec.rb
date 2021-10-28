require "rails_helper"

describe DataExportPolicy do
  let(:divisionA) { create(:division) }
  let(:divisionB) { create(:division, parent: divisionA) }
  let(:divisionC) { create(:division, parent: divisionB) }
  let(:divisionD) { create(:division) }

  describe "permissions" do
    let(:record) { create(:data_export, division: divisionB) }
    subject { described_class.new(user, record) }

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

  describe "scope" do
    let!(:exportA) { create(:data_export, division: divisionA, name: "ExportA") }
    let!(:exportB) { create(:data_export, division: divisionB, name: "ExportB") }
    let!(:exportC) { create(:data_export, division: divisionC, name: "ExportC") }
    subject(:result) { described_class::Scope.new(user, DataExport.all).resolve }

    context "user is member of parent division" do
      let(:user) { create_member(divisionA) }
      it { should contain_exactly(exportA, exportB, exportC) }
    end

    context "user is member of inner division" do
      let(:user) { create_member(divisionB) }
      it { should contain_exactly(exportB, exportC) }
    end

    context "user is member of child division" do
      let(:user) { create_member(divisionC) }
      it { should contain_exactly(exportC) }
    end

    context "user is member of unrelated division" do
      let(:user) { create_member(divisionD) }
      it { should be_empty }
    end
  end
end
