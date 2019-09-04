class DataExportService
  def self.run(data_export)
    data_export.process_data
    data_export.to_csv
  end
end
