class Admin::DataExportsController < Admin::AdminController

  def new
    authorize :data_export
    if params.has_key?(:type)
      set_export_class_on_new
      @data_export = @export_class.new(
        locale_code: I18n.locale,
        division: current_division
      )
    elsif DataExport::DATA_EXPORT_TYPES.count == 1
      redirect_to new_admin_data_export_path(type: DataExport::DATA_EXPORT_TYPES.keys.first)
    else
      render :choose_type
    end
  end

  def create
    @export_class = data_export_create_params[:type].constantize
    @data_export = @export_class.new(data_export_create_params)
    authorize @data_export
    if @data_export.save
      Task.create(
        job_class: DataExportTaskJob,
        job_type_value: 'data_export',
        activity_message_value: 'task_enqueued',
        taskable: @data_export
      ).enqueue(job_params: {data_export_id: @data_export.id})
      flash[:notice] = t("data_exports.create_success")
      redirect_to admin_data_exports_path
    else
      flash[:error] = t("data_exports.create_error")
      render :new
    end
  end

  def index
    authorize :data_export

    @data_exports = DataExport.all

    @data_exports_grid = initialize_grid(
      policy_scope(DataExport),
      include: [:attachments],
      order: "created_at",
      order_direction: "desc",
      per_page: 50,
      name: "data_exports",
      enable_export_to_csv: false
    )

    @csv_mode = false
    @enable_export_to_csv = false

    export_grid_if_requested('data_exports': 'data_exports_grid_definition') do
      # This block only executes if CSV is not being returned
      @csv_mode = false
    end
  end

  def show
    @data_export = DataExport.find(params[:id])
    authorize @data_export
  end

  private

  def set_export_class_on_new
    @export_class = DataExport::DATA_EXPORT_TYPES[data_export_new_params[:type]].constantize
  end

  def data_export_new_params
    params.permit(:type)
  end

  def data_export_create_params
    params.require(:data_export).permit(:type, :division_id, :locale_code, :name, :start_date, :end_date)
  end
end
