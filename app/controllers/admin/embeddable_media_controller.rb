class Admin::EmbeddableMediaController < Admin::AdminController

  def new
    owner_type = params[:owner_type]
    owner_id = params[:owner_id]
    owner_attribute = params[:owner_attribute]
    @record = EmbeddableMedia.new(owner_type: owner_type, owner_id: owner_id, owner_attribute: owner_attribute)
    # need this until migration updated and all developers have newly migrated data
    handle_authorize
    # Note, was getting "undefined method `admin_embeddable_media_index_path'" error if record
    # wasn't saved before rendering form.  Some wackiness related to 'media' pluralization handling?
    @record.save
    render 'linked_sheet'
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
    handle_authorize
    # Note, this can be removed once migration logic is updated and we can assume everybody
    # is working with clean data.
    @record.ensure_migration
    render 'linked_sheet'
  end

  def update
    @record = EmbeddableMedia.find(params[:id])
    handle_authorize

    @record.assign_attributes(record_params)
    @record.parse_key_gid_from_original_url
    if @record.save
      # render plain: "success - display url: #{@record.display_url}"

      # TODO: Use a cleaner way to get loan associated with embeddable media
      owner_type = instance_eval(@record[:owner_type])
      owner_id = @record[:owner_id]
      @item_owner = owner_type.find(owner_id)

      if @item_owner[:custom_value_set_linkable_type] == "Loan"
        @loan = Loan.find(@item_owner[:custom_value_set_linkable_id])
        redirect_to admin_loan_path(@loan, anchor: 'questions'), notice: I18n.t("linked_sheet.notice_saved")
      end
    else
      render :edit
    end
  end

  def destroy
    @record = EmbeddableMedia.find(params[:id])
    handle_authorize
    @record.destroy!
    render plain: "success"
  end

  private

  def handle_authorize
    # need this until migration updated and all developers have newly migrated data
    if @record.owner
      authorize @record
    else
      skip_authorization
    end
  end

  def record_params
    params.require(:embeddable_media).permit(
      :original_url, :sheet_number, :start_cell, :end_cell, :owner_type, :owner_id
    )
  end

end
