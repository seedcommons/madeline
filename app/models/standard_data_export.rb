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

class StandardDataExport < DataExport
  def process_data
    self.custom_data = [
      ["H1", "H2", "H3"],
      ["a", "1", "z"],
      ["b", "2", "y"]
    ]
    self.save
    # call service to create csv
  end
end
