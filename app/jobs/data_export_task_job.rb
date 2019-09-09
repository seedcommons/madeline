class DataExportTaskJob< TaskJob
  def perform(job_params)
    data_export = DataExport.find(job_params[:data_export_id])
    begin
      DataExportService.run(data_export)
    rescue DataExportError => e
      task_for_job(self).set_activity_message("data_export_error")
      raise e
    end
  end
end
