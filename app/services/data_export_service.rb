
class DataExportService
  def self.to_csv(array_of_arrays, path, filename)
    FileUtils.mkdir_p(path)
    CSV.open(File.join(path, filename), "wb") do |csv|
      array_of_arrays.each do |row|
        csv << row
      end
    end
  end
end
