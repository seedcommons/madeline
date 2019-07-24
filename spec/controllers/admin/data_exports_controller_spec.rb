require 'rails_helper'

RSpec.describe Admin::DataExportsController, type: :controller do

  before do
    @user = create(:person, :with_admin_access).user
    sign_in(@user)
  end

  describe "create" do
    it "creates a data export" do
      post :create, params: {data_export: {
        name: "Test Standard Data Export",
        start_date: 1.year.ago,
        end_date: Date.yesterday,
        type: "StandardDataExport",
        locale_code: "en" # move to controller?
      }}
      expect(DataExport.count).to eq 1
      expect(DataExport.first.type).to eq "StandardDataExport"
      expect(Task.count).to eq 1
    end
  end
end
