require 'rails_helper'

describe DataExport, type: :model do
  it "has a valid factory" do
    expect(build(:data_export)).to be_valid
  end

  describe "#to_csv!" do
    let(:export) {
      create(:data_export, data: [
        ['name', 'date', 'description'],
        ['Cool Loan', '2013-07-09', 'A loan for a cool thing that was a good idea to fund']
      ])
    }

    it "generates a CSV" do
      export.to_csv!

      expect(export.reload.attachments).to be_present

      attachment_item = export.attachments.first.item
      csv_data = File.read(attachment_item.path)
      fixture_data = File.read(Rails.root.join('spec', 'fixtures', 'data_export.csv'))

      expect(csv_data[0]).to eq("\xEF\xBB\xBF") # Byte order mark should be at start of file
      expect(csv_data[1..-1]).to eq fixture_data
      expect(File.extname(attachment_item.to_s)).to eq ".csv"
    end

    context "with no data" do
      let(:export) { create(:data_export) }

      it "raises an error" do
        expect { export.to_csv! }.to raise_error ArgumentError
      end
    end

    context "with invalid data" do
      let(:export) { create(:data_export, data: ['one dimensional array']) }

      it "raises an error" do
        expect { export.to_csv! }.to raise_error TypeError
      end
    end

    context "with invalid locale" do
      it "errors" do
        expect(DataExport.new(locale_code: "ice cream").valid?).to be false
      end
    end
  end
end
