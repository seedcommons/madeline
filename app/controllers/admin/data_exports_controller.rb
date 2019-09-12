class Admin::DataExportsController < Admin::AdminController
  before_action :set_export_class, only: :new

  def new
    @data_export = @export_class.new
  end

  private

  def set_export_class
    @export_class = DATA_EXPORT_TYPES[params[:export_type]].constantize
  end
end
