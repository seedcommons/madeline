# == Schema Information
#
# Table name: data_exports
#
#  id          :bigint           not null, primary key
#  data        :json
#  end_date    :datetime
#  locale_code :string           not null
#  name        :string           not null
#  start_date  :datetime
#  type        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  division_id :bigint           not null
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
  # TODO: data exports required to be performed by root admins. This is a workaround
  # because more nuanced permissions will be difficult
  include DivisionBased

  belongs_to :division
  has_many :attachments, as: :media_attachable, dependent: :nullify, class_name: "Media"

  validate :locale_code_available

  before_save :set_name

  DATA_EXPORT_TYPES = {
    "standard_loan_data_export" => "StandardLoanDataExport",
    "enhanced_loan_data_export" => "EnhancedLoanDataExport"
  }

  # Process data should be defined on subclasses,
  # generate a 2D array with the desired data,
  # and save it in the `data` field
  def process_data
    raise NotImplementedError
  end

  def to_csv!
    raise ArgumentError, "No data found" if data.blank?
    raise TypeError, "Data should be a 2D Array" unless (data.is_a?(Array) && data.first.is_a?(Array))

    temp_file = Tempfile.new([name.parameterize, '.csv'])
    CSV.open(temp_file.path, "wb") do |csv|
      data.each do |row|
        csv << row
      end
    end

    media = Media.new(item: temp_file, kind_value: 'document')
    attachments << media
    save!
  end

  def default_name
    export_type_key = DATA_EXPORT_TYPES.invert[self.type.to_s]
    I18n.t(
      "data_exports.default_name",
      type: I18n.t("data_exports.types.#{export_type_key}"),
      current_time: I18n.l(Time.current, format: :long)
    )
  end

  def task
    Task.find_by(taskable_id: self.id)
  end

  def self.model_name
    ActiveModel::Name.new(self, nil, "DataExport")
  end

  private

  def set_name
    self.name = default_name if self.name.blank?
  end

  def locale_code_available
    errors.add(:locale_code, :invalid) unless I18n.available_locales.include?(locale_code.to_sym)
  end
end
