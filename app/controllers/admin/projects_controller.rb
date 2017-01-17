class Admin::ProjectsController < Admin::AdminController
  include TranslationSaveable

  def index
    authorize Project

    @projects_grid = initialize_grid(
      policy_scope(Project),
      order_direction: 'desc',
      per_page: 50,
      name: 'projects',
      enable_export_to_csv: true
    )

    @csv_mode = true

    export_grid_if_requested do
      # This block only executes if CSV is not being returned
      @csv_mode = false
    end
  end
end
