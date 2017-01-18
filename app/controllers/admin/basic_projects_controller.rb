class Admin::BasicProjectsController < Admin::AdminController
  def show
    @project = BasicProject.find(params[:id])
    authorize @project
    prep_form_vars
  end

  private

  def prep_form_vars
    @division_choices = division_choices
    @organization_choices = organization_policy_scope(Organization.in_division(selected_division)).order(:name)
    @agent_choices = person_policy_scope(Person.in_division(selected_division).where(has_system_access: true)).order(:name)
    @currency_choices = Currency.all.order(:name)
  end
end
