class Admin::DivisionsController < Admin::AdminController
  def new
    @report = DataExport.new
  end

  def create
    @report(name, start_date, end_date, type)
    DataExportTask.enqueue
  end
end
