class Admin::DataExportsController < Admin::AdminController
  before_action :set_export_class, only: :new

  def new
    @data_export = @export_class.new
  end

  def create
    # this will be updated to take form params; adding here to create taskable association
    Task.create(
      job_class: DataExportTaskJob,
      job_type_value: 'data_export_task_job',
      activity_message_value: 'task_enqueued',
      taskable: @data_export
    ).enqueue
  end

  private

  def set_export_class
    @export_class = DATA_EXPORT_TYPES[params[:export_type]].constantize
  end
end
