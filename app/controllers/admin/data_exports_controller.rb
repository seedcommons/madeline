class Admin::DataExportsController < Admin::AdminController
  def new
    @report = DataExport.new
  end

  def create
    # TODO: handle locale
    authorize :'data_export', :create?
    data_export = DataExport.create(data_export_params)
    Task.create(
      job_class: DataExportJob,
      job_type_value: :data_export,
      activity_message_value: 'exporting_data'
    ).enqueue(job_params: {data_export_id: data_export.id})
  end

  def data_export_params
    params.require(:data_export).permit(:name, :start_date, :end_date, :type)
  end
end
