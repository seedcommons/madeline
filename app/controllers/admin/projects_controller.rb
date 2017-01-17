class Admin::ProjectsController < Admin::AdminController
  include TranslationSaveable

  def index
    authorize Project
  end
end
