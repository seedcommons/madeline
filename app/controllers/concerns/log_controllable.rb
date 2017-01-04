module LogControllable
  extend ActiveSupport::Concern

  private

  def set_log_form_vars
    @progress_metrics = ProjectLog.progress_metric_options
    @people = Person.by_name
  end

  def authorize_and_render_modal
    authorize @log
    set_log_form_vars
    render "modal", layout: false
  end

  def project_log_params
    params.require(:project_log).permit(*(
      [:agent_id, :date, :project_step_id, :progress_metric_value] +
      translation_params(:summary, :details, :additional_notes, :private_notes)))
  end

  # Renders show partial on success, form partial on failure.
  def save_and_render_partial
    if @log.save
      @step.set_completed!(@log.date) if params[:step_completed_on_date] == '1'
      @expand_logs = true
      render partial: 'admin/project_steps/project_step', locals: {
        step: @step,
        context: 'timeline',
        mode: :show
      }
    else
      render partial: 'admin/project_steps/form', status: :unprocessable_entity, locals: {
        step: @step,
        context: 'timeline',
        mode: :show
      }
    end
  end

  def destroy_and_render_partial
    if @log.destroy
      @expand_logs = @step.logs_count > 0
      render partial: 'admin/project_steps/project_step', locals: {
        step: @step,
        context: 'timeline',
        mode: :show
      }
    end
  end
end
