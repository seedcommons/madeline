class DataExportService
  def self.run(data_export)
    begin
      data_export.process_data
    rescue DataExportError => e
      data_export.to_csv!
      raise e
    end
    data_export.to_csv!
  end
end
