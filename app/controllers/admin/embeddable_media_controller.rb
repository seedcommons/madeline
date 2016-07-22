class Admin::EmbeddableMediaController < Admin::AdminController

  def new
    owner_type = params[:owner_type]
    owner_id = params[:owner_id]
    owner_attribute = params[:owner_attribute]
    @record = EmbeddableMedia.new(owner_type: owner_type, owner_id: owner_id, owner_attribute: owner_attribute)
    authorize @record
    # Note, was getting "undefined method `admin_embeddable_media_index_path'" error if record
    # wasn't saved before rendering form.  Some wackiness related to 'media' pluralization handling?
    @record.save
    render 'linked_sheet', layout: false
  end

  # def create
  #   @record = EmbeddableMedia.new(record_params)
  #   authorize @record
  #   @record.parse_key_gid_from_original_url
  #   if @record.save
  #     render plain: "success"
  #   else
  #     render :show
  #   end
  # end

  def edit
    @record = EmbeddableMedia.find(params[:id])
    authorize @record
    # Note, this can be removed once migration logic is updated and we can assume everybody
    # is working with clean data.
    @record.ensure_migration
    render 'linked_sheet', layout: false
  end

  def update
    @record = EmbeddableMedia.find(params[:id])
    authorize @record
    @record.assign_attributes(record_params)
    @record.parse_key_gid_from_original_url
    if @record.save
      render plain: "success - display url: #{@record.display_url}"
    else
      render :show
    end
  end

  def destroy
    @record = EmbeddableMedia.find(params[:id])
    authorize @record
    @record.destroy!
    render plain: "success"
  end

  private

  def record_params
    params.require(:embeddable_media).permit(
      :original_url, :sheet_number, :start_cell, :end_cell
    )
  end

end

