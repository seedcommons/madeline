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
    "enhanced_loan_data_export" => "EnhancedLoanDataExport",
    "numeric_answer_data_export" => "NumericAnswerDataExport"
  }

  def self.model_name
    ActiveModel::Name.new(self, nil, "DataExport")
  end

  def process_data
    @child_errors = []
    data = []
    data.concat(header_rows)
    scope.find_each do |object|
      begin
        data << hash_to_row(object_data_as_hash(object))
      rescue => e
        Rails.logger.error("Error for loan #{object.id} in data export #{self.name}: #{e}")

        # TODO generalize object beyond loan here and in task show if non-loans exported
        @child_errors << {loan_id: object.id, message: e.message}
        next
      end
    end
    self.update(data: data)

    unless @child_errors.empty?
      raise DataExportError.new(message: "Data export had child errors.", child_errors: @child_errors)
    end
  end

  def to_csv!
    raise ArgumentError, "No data found" if data.blank?
    raise TypeError, "Data should be a 2D Array" unless (data.is_a?(Array) && data.first.is_a?(Array))

    temp_file = Tempfile.new([name.parameterize, '.csv'])
    CSV.open(temp_file.path, "wb") do |csv|
      # Write byte order mark at start of file to help Excel with accented characters
      csv.to_io.write("\xEF\xBB\xBF")
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

  protected

  def insert_in_row(header_symbol, row_array, value)
    row_array[header_symbols_to_indices[header_symbol]] = value
  end

  private

  def hash_to_row(hash)
    data_row = []
    hash.each { |k, v| insert_in_row(k, data_row, v) }
    data_row
  end

  # Builds a hash of header symbols to their appropriate indices in the row arrays.
  def header_symbols_to_indices
    @header_symbols_to_indices = header_symbols.each_with_index.to_h
  end

  def set_name
    self.name = default_name if self.name.blank?
  end

  def locale_code_available
    errors.add(:locale_code, :invalid) unless I18n.available_locales.include?(locale_code.to_sym)
  end
end
