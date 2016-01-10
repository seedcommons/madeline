class Admin::Raw::ProjectStepsController < BaseCrudController


  protected

  def clazz
    ProjectStep
  end


  # fields needed for initial model creation
  def create_attrs
    [:project_id, :project_type, :agent_id]
  end

  def update_attrs
    [:project_id, :project_type, :agent_id,
     :scheduled_date, :completed_date, :is_finalized, :summary, :details]
  end






end
