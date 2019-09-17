class Admin::DataExportsController < Admin::AdminController
  before_action :set_export_class, only: :new

  def new
    @data_export = @export_class.new
  end

  def create
    # TODO: update to take form params (issue 10017); adding here to create taskable association
    @data_export = StandardLoanDataExport.create(
      start_date: Date.parse("2019-01-01"),
      end_date: Date.parse("2019-09-01")
    )
    Task.create(
      job_class: DataExportTaskJob,
      job_type_value: 'data_export_task_job',
      activity_message_value: 'task_enqueued',
      taskable: @data_export
    ).enqueue(job_params: {data_export_id: @data_export.id})
  end

  private

  def set_export_class
    @export_class = DATA_EXPORT_TYPES[params[:export_type]].constantize
  end
end
