class Admin::EmbeddableMediaController < Admin::AdminController

  def show
    @record = EmbeddableMedia.find(params[:id])
    #authorize @record
    skip_authorization
    @record.ensure_migration
    render 'linked_spreadsheet', layout: false
  end

  def new
    @record = EmbeddableMedia.new
#    authorize @record
    skip_authorization
  end

  def create
    @record = EmbeddableMedia.new(record_params)
#    authorize @record
    skip_authorization
    @record.parse_key_gid_from_original_url
    @record.save!
    redirect_to display_path, notice: I18n.t(:notice_created)
  end

  def edit
    @record = EmbeddableMedia.find(params[:id])
    #authorize @record
    skip_authorization
    @record.ensure_migration
    render 'linked_spreadsheet', layout: false
  end


  def update
    @record = EmbeddableMedia.find(params[:id])
#    authorize @record
    skip_authorization
#    @record.update!(record_params)
#    redirect_to display_path, notice: I18n.t(:notice_updated)

    puts "update - params: #{record_params}"

    @record.assign_attributes(record_params)
    @record.parse_key_gid_from_original_url

    if @record.save
      render plain: "success"
    else
      render :show
    end

  end

  def destroy
    @record = CustomValueSet.find(params[:id])
#    authorize @record
    skip_authorization
    @record.destroy!
    redirect_to display_path, notice: I18n.t(:notice_deleted)
  end

  private

  def record_params
    params.require(:embeddable_media).permit(
      :original_url, :sheet_number, :start_cell, :end_cell
    )
  end

end

