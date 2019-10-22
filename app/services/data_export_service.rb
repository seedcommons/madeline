class DataExportService
  def self.run(data_export)
    begin
      I18n.with_locale(data_export.locale_code) do
        data_export.process_data
      end
    rescue DataExportError => e
      data_export.to_csv!
      raise e
    end
    data_export.to_csv!
  end
end
