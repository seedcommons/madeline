class Admin::MediaController < Admin::AdminController
  include TranslationSaveable

  before_action :find_attachable, :find_media, :authorize_media

  def new
    render_modal_partial
  end

  def edit
    render_modal_partial
  end

  def create
    @media.assign_attributes(media_params)
    if @media.save
      render partial: "admin/media/index", locals: {owner: @media.media_attachable}
    else
      render_modal_partial(status: 422)
    end
  end
  alias_method :update, :create

  def destroy
    @media.destroy

    if request.xhr?
      render partial: "admin/media/index", locals: {owner: @attachable}
    else
      redirect_to [:admin, @attachable]
    end
  end

  private

  def find_media
    @media = Media.find_or_initialize_by(id: params[:id], media_attachable: @attachable)
  end

  def find_attachable
    @attachable = params[:attachable_type].singularize.classify.constantize.find(params[:attachable_id])
  end

  def authorize_media
    authorize @attachable
    authorize @media
  end

  def render_modal_partial(status: 200)
    link_params = @media.attributes.slice(:attachable_id, :attachable_type)
    @submit_url = @media.new_record? ? admin_media_index_path(link_params) : admin_media_path(link_params)
    render partial: "admin/media/modal_content", status: status
  end

  def media_params
    params.require(:media).permit(*([:item] + translation_params(:caption, :description)))
  end
end
