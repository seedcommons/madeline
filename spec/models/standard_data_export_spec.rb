# == Schema Information
#
# Table name: data_exports
#
#  attachment  :string
#  created_at  :datetime         not null
#  custom_data :json
#  end_date    :date
#  id          :bigint(8)        not null, primary key
#  locale_code :string
#  name        :string
#  start_date  :date
#  type        :string
#  updated_at  :datetime         not null
#

require 'rails_helper'

RSpec.describe StandardDataExport, type: :model do
  describe "process data" do
    let(:data_export) { create(:standard_data_export) }
    it "adds data to data export" do
      expect(data_export.custom_data).to be_nil
      expect(data_export.type).to eq "StandardDataExport"
      data_export.process_data
      expect(data_export.custom_data).not_to be_nil
    end

    it "creates attachment" do
      expect(data_export.attachment.file).to be_nil
      data_export.process_data
      expect(data_export.attachment.file).not_to be_nil
      puts data_export.attachment.read
      puts data_export.attachment.path
      expect(data_export.attachment.read).to include("H2")
    end
  end
end
