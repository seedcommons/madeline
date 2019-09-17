require 'rails_helper'

describe DataExportService do
  describe "run" do
    let(:data_export) { create(:standard_loan_data_export) }

    it "populates data and creates csv" do
      DataExportService.run(data_export)
      expect(data_export.reload.data.present?).to be true
      expect(data_export.attachments.size).to be 1
    end
  end
end
