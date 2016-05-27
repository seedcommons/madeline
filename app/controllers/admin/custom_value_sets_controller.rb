class Admin::PeopleController < Admin::AdminController
  # show view includes edit
  def show
    @record = CustomValueSet.find(params[:id])
    authorize @record
    prep_form_vars
  end

  def new
    raise "'linkable_type' param required" unless params[:linkable_type].present?
    raise "'linkable_id' param required" unless params[:linkable_id].present?
    raise "'field_set_id' param required" unless params[:field_set_id].present?
    linkable = resolve_polymorphic(params[:linkable_type], params[:linkable_id])
    field_set = CustomFieldSet.find(params[:field_set_id])
    @record = CustomValueSet.new(custom_value_set_linkable: linkable, custom_field_set: field_set)
    authorize @record
    prep_form_vars
  end

  def update
    @record = CustomValueSet.find(params[:id])
    authorize @record

    if @record.update(record_params)
      redirect_to record_path(@record), notice: I18n.t(:notice_updated)
    else
      prep_form_vars
      render :show
    end
  end

  def create
    @record = CustomValueSet.new(record_params)
    authorize @record

    if @record.save
      redirect_to record_path(@record), notice: I18n.t(:notice_created)
    else
      prep_form_vars
      render :new
    end
  end

  def destroy
    @record = CustomValueSet.find(params[:id])
    authorize @record

    if @record.destroy
      redirect_to record_path(@record), notice: I18n.t(:notice_deleted)
    else
      prep_form_vars
      render :show
    end
  end

  private

  def resolve_polymorphic(type, id)
    type.constantize.find(id)
  end

  def record_path(record)
    #4301 Todo: Consider LoanQuestionairesController subclass
    if record.custom_value_set_linkable.is_a?(Loan)
      admin_loan_path(record.custom_value_set_linkable)
    else
      raise "Unexpected custom_value_set_linkable: #{record.custom_value_set_linkable}"
    end
  end

  def record_params
    params.require(:custom_value_set).permit(
      :custom_value_set_linkable_type, :custom_value_set_linkable_id, :custom_field_set_id,
    )
  end

  def prep_form_vars
  end

end
