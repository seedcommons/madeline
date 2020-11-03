require 'rails_helper'

describe DataExportService do
  describe "run" do
    let(:data_export) { create(:standard_loan_data_export, locale_code: :es) }

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

    context "translation" do
      let!(:division) { create(:division, :with_accounts) }
      let!(:loan) { create(:loan, :active, division: division, rate: 3.0) }

      before do
        # Note, option_set functionality depends on existance of root_division.
        # So if we're not going to enable autocreation within the 'Division.root' logic, then we need
        # to explicitly guarantee existence of the root division for any unit tests which use option sets
        root_division
        option_set = Loan.status_option_set
        option_set.options.create(value: 'active', label_translations: {en: 'Active', es: 'Activo'})
        option_set.options.create(value: 'completed', label_translations: {en: 'Completed', es: "Completo"})
      end

      it "uses data export's locale rather than system locale" do
        expect(I18n.locale).to eq :en
        DataExportService.run(data_export)
        data = data_export.reload.data
        headers = data[0]
        status_index = headers.index("Estado")
        expect(data[1][status_index]).to eq "Activo"
      end
    end
  end
end
