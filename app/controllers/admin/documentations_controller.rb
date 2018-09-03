class Admin::DocumentationsController < Admin::AdminController
  include TranslationSaveable

  before_action :find_documentation, only: [:edit, :show, :update]

  def new
    @documentation = Documentation.new(html_identifier: params[:html_identifier])
    authorize @documentation

    @documentation.previous_url = request.referrer

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
      redirect_to @documentation.previous_url, notice: I18n.t(:notice_created)
    else
      render :new
    end
  end

  def update
    if @documentation.update(documentation_params)
      # TODO: placeholder till other actions are defined
      redirect_to @documentation.previous_url, notice: I18n.t(:notice_updated)
    else
      render :edit
    end
  end

  private

  def documentation_params
    params.require(:documentation).permit(*([:html_identifier,
      :calling_action, :calling_controller, :previous_url
    ] + translation_params(:summary_content, :page_content, :page_title)))
  end

  def find_documentation
    @documentation = Documentation.find(params[:id])
    authorize @documentation
  end
end
