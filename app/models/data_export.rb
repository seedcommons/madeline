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

class DataExport < ApplicationRecord
  include DivisionBased

  belongs_to :division
  has_many :attachments, as: :media_attachable, dependent: :nullify

  before_save :set_name

  DATA_EXPORT_TYPES = {
    "data_export" => "DataExport"
  }

  private

  def set_name
    export_type_key = DATA_EXPORT_TYPES.invert[self.type.to_s]

    self.name ||= I18n.t(
      "data_exports.default_name",
      type: I18n.t("data_exports.types.#{export_type_key}"),
      current_date: I18n.l(Time.zone.now, format: :short)
    )
  end
end
