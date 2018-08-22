class Admin::DocumentationsController < Admin::AdminController
  include TranslationSaveable

  def new
    @documentation = Documentation.new(html_identifier: params[:html_identifier])
    authorize @documentation

    if params[:caller]
      controller_action = params[:caller].split('#')
      @documentation.calling_controller = controller_action[0]
      @documentation.calling_action = controller_action[1]
    end
  end

  def create
    @documentation = Documentation.new(documentation_params)
    authorize @documentation

    if @documentation.save
      # TODO: placeholder till other actions are defined
      redirect_to root_path, notice: I18n.t(:notice_created)
    else
      render :new
    end
  end

  private

  def documentation_params
    params.require(:documentation).permit(*([:html_identifier,
      :calling_action, :calling_controller] + translation_params(:summary_content, :page_content)))
  end
end
