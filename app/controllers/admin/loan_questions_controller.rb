class Admin::LoanQuestionsController < Admin::AdminController
  include TranslationSaveable
  before_action :set_loan_question, only: [:show, :edit, :update, :destroy, :move]

  def index
    authorize CustomField
    # Hide retired questions for now
    @questions = CustomField.loan_questions.where(status: [:active, :inactive])
    @json = ActiveModel::Serializer::CollectionSerializer.new(@questions.roots).to_json
  end

  def new
    @parent_id = params[:parent_id]
    field_set_name = params[:fieldset]
    field_set = CustomFieldSet.find_by(internal_name: 'loan_' + field_set_name)
    @loan_question = field_set.custom_fields.build
    authorize @loan_question
    @loan_question.build_complete_requirements
    render_form
  end

  def edit
    @loan_question.build_complete_requirements
    @requirements = @loan_question.custom_field_requirements
    # TODO: Restore @requirements to item similar to below
    # Using this line results in the following error for the below line:
      # undefined method `label' for nil:NilClass:
    # @requirements = @loan_question.custom_field_requirements.sort_by { |i| i.loan_type.label.text }
    render_form
  end

  def create
    @loan_question = CustomField.new(loan_question_params)
    authorize @loan_question
    if @loan_question.save
      render json: @loan_question.reload
    else
      render_form(status: :unprocessable_entity)
    end
  end

  def update
    if @loan_question.update(loan_question_params)
      render json: @loan_question.reload
    else
      render_form(status: :unprocessable_entity)
    end
  end

  def move
    target = CustomField.find(params[:target])
    method = case params[:relation]
      when 'before' then :prepend_sibling
      when 'after' then :append_sibling
      when 'inside' then :prepend_child
    end

    target.send(method, @loan_question)
    head :no_content
  rescue
    flash.now[:error] = I18n.t('loan_questions.move_error') + ": " + $!.to_s
    render partial: 'application/alerts', status: :unprocessable_entity
  end

  def destroy
    @loan_question.destroy!
    head :no_content
  rescue
    flash.now[:error] = I18n.t('loan_questions.delete_error') + ": " + $!.to_s
    render partial: 'application/alerts', status: :unprocessable_entity
  end

  private

    def set_loan_question
      @loan_question = CustomField.find(params[:id])
      authorize @loan_question
    end

    def loan_question_params
      # This `delete_if` is required when raising an error on unpermitted params.
      # However, it should be abstracted somehow so it applies to all controllers.
      # params.require(:custom_field).delete_if { |k, v| k =~ /^locale_/ }.permit(
      params.require(:custom_field).permit(
        :label, :data_type, :parent_id, :position,
        :custom_field_set_id, :has_embeddable_media, :override_associations,
        *translation_params(:label, :explanation),
        custom_field_requirements_attributes: [:id, :amount, :option_id, :_destroy]
      )
    end

    def render_form(status: nil)
      @data_types = CustomField::DATA_TYPES.map do |i|
        [I18n.t("simple_form.options.custom_field.data_type.#{i}"), i]
      end.sort
      if status
        render partial: 'form', status: :status
      else
        render partial: 'form'
      end
    end
end
