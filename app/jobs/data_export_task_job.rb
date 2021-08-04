class DataExportTaskJob < TaskJob
  def perform(job_params)
    data_export = DataExport.find(job_params[:data_export_id])
    begin
      task_for_job(self).set_activity_message("in_progress")
      ::DataExportService.run(data_export)
    rescue DataExportError => e
      task_for_job(self).update(custom_error_data: e.child_errors)
      raise e
    end
    task_for_job(self).set_activity_message("completed")
  end

  rescue_from(DataExportError) do |error|
    task_for_job(self).set_activity_message("finished_with_custom_error_data")
    task_for_job(self).fail!
    notify_of_error(error)
    raise error
  end
end
