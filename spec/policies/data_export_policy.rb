require 'rails_helper'

describe DataExportPolicy do
  subject { described_class.new(user, record) }

  let(:record) { create(:data_export) }

  context "user is a root division admin" do
    let(:user) { create_admin(root_division) }
    it { should permit_all }
  end

  context "user is admin of non root division" do
    let(:other_division) { create(:division) }
    let(:user) { create_admin(other_division) }
    it { should forbid_all }
  end

  context "user is non admin of root division" do
    let(:user) { create(:user, division: root_division) }
    it { should forbid_all }
  end
end
