# Wraps full quickbooks fetch as task job so that
# its status can be queried and displayed
class DataExportJob < TaskJob
  def perform(job_params)
    data_export = DataExport.find(job_params[:data_export_id])
    data_export.process_data
  end
end
