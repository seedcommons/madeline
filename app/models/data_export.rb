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

class DataExport < ApplicationRecord
  def process_data
    raise NotImplementedError
  end
end
