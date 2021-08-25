class Admin::QuestionsController < Admin::AdminController
  include TranslationSaveable
  before_action :set_question, only: [:edit, :update, :destroy, :move]

  def index
    authorize Question
    sets = QuestionSet.where(internal_name: %w(loan_criteria loan_post_analysis)).to_a
    @questions = sets.map { |s| top_level_questions(s) }.flatten
    @questions = ActiveModel::Serializer::CollectionSerializer.new(@questions, selected_division: selected_division)
  end

  def new
    set = QuestionSet.find_by(internal_name: "loan_#{params[:set]}")
    parent = params[:parent_id].present? ? Question.find(params[:parent_id]) : set.root_group
    @question = Question.new(question_set_id: set.id, parent: parent, division: current_division)
    authorize @question
    @question.build_complete_requirements
    render_form
  end

  def edit
    @question.build_complete_requirements
    @requirements = @question.loan_question_requirements.sort_by { |i| i.loan_type.label.text }
    render_form
  end

  def create
    @question = Question.new(question_params)
    authorize @question
    if @question.save
      render_set_json(@question.question_set)
    else
      @question.build_complete_requirements
      render_form(status: :unprocessable_entity)
    end
  end

  def update
    if @question.update(question_params)
      render_set_json(@question.question_set)
    else
      render_form(status: :unprocessable_entity)
    end
  end

  def move
    target = Question.find(params[:target])
    current_division = selected_division || Division.root
    QuestionMover.new(current_division: current_division, question: @question,
                      target: target, relation: params[:relation].to_sym).move
    render_set_json(@question.question_set)
  rescue ArgumentError
    flash.now[:error] = I18n.t('questions.move_error') + ": " + $!.to_s
    render partial: 'application/alerts', status: :unprocessable_entity
  end

  def destroy
    @question.destroy!
    render_set_json(@question.question_set)
  rescue
    flash.now[:error] = I18n.t('questions.delete_error') + ": " + $!.to_s
    render partial: 'application/alerts', status: :unprocessable_entity
  end

  private

  def render_set_json(set)
    render json: top_level_questions(set), selected_division: selected_division
  end

  def top_level_questions(set)
    FilteredQuestion.new(set.root_group_preloaded, selected_division: selected_division,
                                                   include_descendant_divisions: true).children
  end

  def set_question
    @question = Question.find(params[:id])
    authorize @question
  end

  def question_params
    # This `delete_if` is required when raising an error on unpermitted params.
    # However, it should be abstracted somehow so it applies to all controllers.
    # params.require(:question).delete_if { |k, v| k =~ /^locale_/ }.permit(
    params.require(:question).permit(
      :label, :data_type, :division_id, :display_in_summary, :parent_id,
      :question_set_id, :has_embeddable_media, :override_associations, :active,
      *translation_params(:label, :explanation),
      loan_question_requirements_attributes: [:id, :amount, :option_id, :_destroy]
    )
  end

  def render_form(status: nil)
    @data_types = Question::DATA_TYPES.map do |i|
      [I18n.t("simple_form.options.question.data_type.#{i}"), i]
    end.sort

    render partial: 'form', status: status
  end
end
