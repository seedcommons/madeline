class Admin::CustomValueSetsController < Admin::AdminController
  # show view includes edit
  def show
    @record = CustomValueSet.find(params[:id])
    authorize @record
  end

  def new
    raise "'linkable_type' param required" unless params[:linkable_type].present?
    raise "'linkable_id' param required" unless params[:linkable_id].present?
    raise "'linkable_attribute' param required" unless params[:linkable_attribute].present?
    raise "'field_set_name' param required" unless params[:field_set_name].present?

    linkable = resolve_polymorphic(params[:linkable_type], params[:linkable_id])
    field_set = CustomFieldSet.find_by(internal_name: params[:field_set_name])
    linkable_attribute = params[:linkable_attribute]
    @record = CustomValueSet.new(custom_value_set_linkable: linkable, custom_field_set: field_set,
      linkable_attribute: linkable_attribute)
    authorize @record
  end

  def update
    @record = CustomValueSet.find(params[:id])
    authorize @record

    if @record.update(record_params)
      redirect_to display_path, notice: I18n.t(:notice_updated)
    else
      render :show
    end
  end

  def create
    @record = CustomValueSet.new(record_params)
    authorize @record

    if @record.save
      redirect_to display_path, notice: I18n.t(:notice_created)
    else
      render :new
    end
  end

  def destroy
    @record = CustomValueSet.find(params[:id])
    authorize @record

    if @record.destroy
      redirect_to display_path, notice: I18n.t(:notice_deleted)
    else
      render :show
    end
  end

  private

  def resolve_polymorphic(type, id)
    type.constantize.find(id)
  end

  def record_params
    params.require(:custom_value_set).permit!
  end

  def custom_attributes
    custom_field_set.depth_first_fields.map(&:attribute_sym)
  end

  def display_path
    admin_loan_path(@record.custom_value_set_linkable) + "#criteria"

    # This version will rerender as a top level.  Useful for debugging
    # if record.custom_value_set_linkable.is_a?(Loan)
    #   admin_loan_path(record.custom_value_set_linkable)
    # else
    #   raise "Unexpected custom_value_set_linkable: #{record.custom_value_set_linkable}"
    # end
  end

end
