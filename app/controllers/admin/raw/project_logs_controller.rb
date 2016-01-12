class Admin::Raw::ProjectLogsController < BaseCrudController

  protected

  # fields needed for initial model creation
  def create_attrs
    [:project_step_id, :agent_id]
  end

  # full list of attributes which may be assigned from the form
  def update_attrs
    [:project_step_id, :agent_id, :progress_metric_option_id, :date,
     :summary, :details, :additional_notes, :private_notes  # translatable
    ]
  end


end
