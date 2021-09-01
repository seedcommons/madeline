class Admin::DocumentationsController < Admin::AdminController
  include TranslationSaveable

  before_action :find_documentation, only: [:edit, :show, :update]

  def index
    @documentations = policy_scope(Documentation.includes(:division)).group_by(&:calling_controller)
    authorize Documentation
  end

  def new
    @documentation = Documentation.new(html_identifier: params[:html_identifier],
                                       division: selected_division_or_root)
    authorize @documentation

    @previous_url = request.referer

    if params[:caller]
      controller_action = params[:caller].split('#')
      @documentation.calling_controller = controller_action[0]
      @documentation.calling_action = controller_action[1]
    end
  end

  def edit
    authorize @documentation
    @previous_url = request.referer
  end

  def create
    @documentation = Documentation.new(documentation_params)
    @documentation.division = selected_division_or_root
    authorize @documentation

    if @documentation.save
      redirect_to params[:previous_url], notice: I18n.t(:notice_created)
    else
      render :new
    end
  end

  def update
    if @documentation.update(documentation_params)
      redirect_to params[:previous_url], notice: I18n.t(:notice_updated)
    else
      render :edit
    end
  end

  private

  def documentation_params
    params.require(:documentation).permit(*([:html_identifier,
      :calling_action, :calling_controller
    ] + translation_params(:summary_content, :page_content, :page_title)))
  end

  def find_documentation
    @documentation = Documentation.find(params[:id])
    authorize @documentation
  end
end
