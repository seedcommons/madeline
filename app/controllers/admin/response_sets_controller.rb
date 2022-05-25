class Admin::ResponseSetsController < Admin::AdminController
  include QuestionnaireRenderable

  def create
    @response_set = ResponseSet.new
    @response_set.assign_attributes(response_set_params.merge(updater_id: current_user.id))
    authorize @response_set

    # Check if loan already has a response set (e.g. created in another tab)
    @conflicting_response_set = ResponseSet.find_by(loan_id: @response_set.loan_id,
                                                    question_set_id: @response_set.question_set_id)
    if @conflicting_response_set
      @response_set_from_db = {
        updater: @conflicting_response_set.updater,
        updated_at: @conflicting_response_set.updated_at,
        lock_version: @conflicting_response_set.lock_version,
      }
      handle_conflict
    else
      @response_set.save!
      redirect_to display_path, notice: I18n.t(:notice_created)
    end
  end

  def update
    @response_set = ResponseSet.find(params[:id])
    authorize @response_set

    # Need to store these values from the db before they get overwritten by params below
    @response_set_from_db = {
      updater: @response_set.updater,
      updated_at: @response_set.updated_at,
      lock_version: @response_set.lock_version,
    }

    # Add updater id to params
    adjusted_params = response_set_params.merge(updater_id: current_user.id)
    # If there was a conflict and "Overwrite" was clicked, update the lock version to the one pulled
    # from the database when the warning was displayed. We do this instead of just ignoring the
    # lock_version in case someone made further changes since the warning was displayed. This way,
    # another, updated warning will be displayed instead of going ahead with the update.
    adjusted_params[:lock_version] = params[:new_lock_version] if params[:overwrite]

    if params[:discard]
      redirect_to display_path
    else
      @response_set.update!(adjusted_params)
      redirect_to display_path, notice: I18n.t(:notice_updated)
    end
  rescue ActiveRecord::StaleObjectError
    handle_conflict
  end

  def destroy
    @response_set = ResponseSet.find(params[:id])
    authorize @response_set
    @response_set.destroy!
    redirect_to display_path, notice: I18n.t(:notice_deleted)
  end

  private

  def handle_conflict
    @conflict = true
    @tab = 'questions'
    @question_set = @response_set.question_set
    @loan = @response_set.loan
    prep_questionnaire
    render 'admin/loans/show'
  end

  def resolve_polymorphic(type, id)
    type.constantize.find(id)
  end

  def response_set_params
    params.require(:response_set).permit(:loan_id, :question_set_id, :lock_version,
      answers_attributes: [:id, :question_id, :text_data, :numeric_data, :not_applicable])
  end

  def display_path
    admin_loan_tab_path(@response_set.loan, tab: 'questions', qset: @response_set.question_set_id)
  end
end
