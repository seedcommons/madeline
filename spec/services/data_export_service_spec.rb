require 'rails_helper'

describe DataExportService do
  describe "run" do
    let(:data_export) { create(:standard_loan_data_export) }

    it "populates data and creates csv" do
      DataExportService.run(data_export)
      expect(data_export.reload.data.present?).to be true
      expect(data_export.attachments.size).to be 1
    end

    context "data export error is raised" do
      before do
        expect(data_export).to receive(:process_data) do
          data_export.update(data: [
            ['name', 'date', 'description'],
            ['Cool Loan', '2013-07-09', 'A loan for a cool thing that was a good idea to fund']
          ])
          raise DataExportError
        end
      end

      it "creates csv and re-raises error" do
        expect { DataExportService.run(data_export) }.to raise_error(DataExportError)
        expect(data_export.attachments.size).to be 1
      end
    end
  end
end
