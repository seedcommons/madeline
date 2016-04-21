class Admin::MediaController < Admin::AdminController
  before_action :find_attachable
  before_action :find_media


  def new
    authorize @attachable
    authorize @media
    @available_locales = current_division.resolve_default_locales || I18n.available_locales
  end

  def edit
    authorize @attachable
    authorize @media
    @available_locales = current_division.resolve_default_locales || I18n.available_locales
  end

  def update
    authorize @attachable
    authorize @media
    Rails.logger.ap media_params
    @media.update_attributes(media_params)


    redirect_to [:admin, @attachable]
  end

  def show

  end

  def destroy

  end

  private

  def find_media
    @media = Media.find_or_initialize_by(id: params[:id], media_attachable: @attachable)
  end

  def find_attachable
    @attachable = params[:media_attachable_type].classify.constantize.find(params[:media_attachable_id])
  end

  def media_params
    params.require(:media).permit(:item, :caption_en, :caption_es, :'caption_es-AR', :caption_fr)
  end
end
