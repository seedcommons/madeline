class Admin::MediaController < Admin::AdminController
  before_action :find_attachable
  before_action :find_media

  def update
    authorize @attachable
    authorize @media
    @media.update_attributes(media_params)

    redirect_to [:admin, @attachable]
  end
  alias_method :create, :update

  def destroy
    authorize @attachable
    authorize @media
    @media.destroy

    redirect_to [:admin, @attachable]
  end

  private

  def find_media
    @media = Media.find_or_initialize_by(id: params[:id], media_attachable: @attachable)
  end

  def find_attachable
    @attachable = params[:media_attachable_type].classify.constantize.find(params[:media_attachable_id])
  end

  def media_params
    # TODO: Generic method for whitelisting translatable params as part of Translatable module
    params.require(:media).permit(:item, :caption_en, :caption_es, :'caption_es-AR', :caption_fr)
  end
end
