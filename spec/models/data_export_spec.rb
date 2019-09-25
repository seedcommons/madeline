# == Schema Information
#
# Table name: data_exports
#
#  created_at  :datetime         not null
#  data        :json
#  division_id :bigint(8)        not null
#  end_date    :datetime
#  id          :bigint(8)        not null, primary key
#  locale_code :string           not null
#  name        :string           not null
#  start_date  :datetime
#  type        :string           not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_data_exports_on_division_id  (division_id)
#
# Foreign Keys
#
#  fk_rails_...  (division_id => divisions.id)
#

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

      expect(csv_data).to eq fixture_data
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
