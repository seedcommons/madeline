class Admin::TasksController < Admin::AdminController
  def index
    authorize :'task', :index?
    @params = {status: params[:status], pg: params[:pg]}
    @tasks = Task.all.page(params[:pg]).per(3).order('created_at DESC')
  end
end
