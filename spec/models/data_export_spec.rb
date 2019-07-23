# == Schema Information
#
# Table name: data_exports
#
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

RSpec.describe DataExport, type: :model do
  describe "process data" do
    let(:data_export) { create(:data_export) }
    it "adds data to data export" do
      data_export.process_data
      expect(data_export.custom_data).not_to be_nil
    end
  end
end
