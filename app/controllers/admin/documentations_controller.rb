class Admin::DocumentationsController < Admin::AdminController

  def new
    @documentation = Documentation.new(html_identifier: params[:html_identifier])
    authorize @documentation, :new?
  end

  def create
  end

  private

  def documentation_params
    params.require(:documentation).permit(:html_identifier, :calling_action, :calling_controller)
  end
end
