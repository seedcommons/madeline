class Admin::CustomValueSetsController < Admin::AdminController
  def create
    @record = CustomValueSet.new(record_params)
    authorize @record
    @record.save!
    redirect_to display_path, notice: I18n.t(:notice_created)
  end

  def update
    @record = CustomValueSet.find(params[:id])
    authorize @record
    @record.update!(record_params)
    redirect_to display_path, notice: I18n.t(:notice_updated)
  end

  def destroy
    @record = CustomValueSet.find(params[:id])
    authorize @record
    @record.destroy!
    redirect_to display_path, notice: I18n.t(:notice_deleted)
  end

  private

  def resolve_polymorphic(type, id)
    type.constantize.find(id)
  end

  def record_params
    params.require(:custom_value_set).permit!
  end

  def display_path
    admin_loan_path(@record.custom_value_set_linkable,
      selected: @record.linkable_attribute.sub(/^loan_/, ""),
      anchor: "questions")
  end
end


