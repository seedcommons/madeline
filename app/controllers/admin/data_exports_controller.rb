class Admin::DataExportsController < Admin::AdminController

  def new
    authorize :data_export
    if params.has_key?(:type)
      set_export_class_on_new
      @data_export = @export_class.new(
        locale_code: I18n.locale,
        division: current_division
      )
    else
      render :choose_type
    end
  end

  def create
    @export_class = data_export_create_params[:type].constantize
    @data_export = @export_class.new(data_export_create_params)
    authorize @data_export
    # TODO: update to take form params (issue 10017); adding here to create taskable association
    if @data_export.save
      Task.create(
        job_class: DataExportTaskJob,
        job_type_value: 'data_export_task_job',
        activity_message_value: 'task_enqueued',
        taskable: @data_export
      ).enqueue(job_params: {data_export_id: @data_export.id})
    else
      render :new
    end
  end

  private

  def set_export_class_on_new
    @export_class = DataExport::DATA_EXPORT_TYPES[data_export_new_params[:type]].constantize
  end

  def data_export_new_params
    params.permit(:type)
  end

  def data_export_create_params
    params.require(:data_export).permit(:type, :division_id, :locale_code, :name)
  end
end
