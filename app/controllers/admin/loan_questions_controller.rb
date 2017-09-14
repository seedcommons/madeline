class Admin::LoanQuestionsController < Admin::AdminController
  include TranslationSaveable
  before_action :set_loan_question, only: [:show, :edit, :update, :destroy, :move]

  def index
    authorize LoanQuestion
    # Hide retired questions for now
    sets = LoanQuestionSet.where(internal_name: %w(loan_criteria loan_post_analysis)).to_a
    @json = ActiveModel::Serializer::CollectionSerializer.new(
      sets.map { |s| FilteredQuestion.new(s.root_group_preloaded).children }.flatten,
        user: current_user
    ).to_json
  end

  def new
    set = LoanQuestionSet.find_by(internal_name: "loan_#{params[:set]}")
    parent = params[:parent_id].present? ? LoanQuestion.find(params[:parent_id]) : set.root_group
    @loan_question = LoanQuestion.new(loan_question_set_id: set.id, parent: parent,
      division: current_division)
    authorize @loan_question
    @loan_question.build_complete_requirements
    render_form
  end

  def edit
    @loan_question.build_complete_requirements
    @requirements = @loan_question.loan_question_requirements.sort_by { |i| i.loan_type.label.text }
    render_form
  end

  def create
    @loan_question = LoanQuestion.new(loan_question_params)
    authorize @loan_question
    if @loan_question.save
      render_set_json(@loan_question.loan_question_set)
    else
      render_form(status: :unprocessable_entity)
    end
  end

  def update
    if @loan_question.update(loan_question_params)
      render_set_json(@loan_question.loan_question_set)
    else
      render_form(status: :unprocessable_entity)
    end
  end

  def move
    target = LoanQuestion.find(params[:target])
    method = case params[:relation]
      when 'before' then :prepend_sibling
      when 'after' then :append_sibling
      when 'inside' then :prepend_child
    end

    target.send(method, @loan_question)
    render_set_json(@loan_question.loan_question_set)
  rescue
    flash.now[:error] = I18n.t('loan_questions.move_error') + ": " + $!.to_s
    render partial: 'application/alerts', status: :unprocessable_entity
  end

  def destroy
    @loan_question.destroy!
    render_set_json(@loan_question.loan_question_set)
  rescue
    flash.now[:error] = I18n.t('loan_questions.delete_error') + ": " + $!.to_s
    render partial: 'application/alerts', status: :unprocessable_entity
  end

  private

  def render_set_json(set)
    render json: FilteredQuestion.new(set.root_group_preloaded).children, user: current_user
  end

  def set_loan_question
    @loan_question = LoanQuestion.find(params[:id])
    authorize @loan_question
  end

  def loan_question_params
    # This `delete_if` is required when raising an error on unpermitted params.
    # However, it should be abstracted somehow so it applies to all controllers.
    # params.require(:loan_question).delete_if { |k, v| k =~ /^locale_/ }.permit(
    params.require(:loan_question).permit(
      :label, :data_type, :division_id, :parent_id, :position,
      :loan_question_set_id, :has_embeddable_media, :override_associations, :status,
      *translation_params(:label, :explanation),
      loan_question_requirements_attributes: [:id, :amount, :option_id, :_destroy]
    )
  end

  def render_form(status: nil)
    @data_types = LoanQuestion::DATA_TYPES.map do |i|
      [I18n.t("simple_form.options.loan_question.data_type.#{i}"), i]
    end.sort
    if status
      render partial: 'form', status: :status
    else
      render partial: 'form'
    end
  end
end
