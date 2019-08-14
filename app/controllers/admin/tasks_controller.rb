class Admin::TasksController < Admin::AdminController
  def index
    authorize :'task', :index?
    @params = {status: params[:status], pg: params[:pg]}
    @tasks = Task.all.page(params[:pg]).per(20).order('created_at DESC')
  end

  def show
    authorize :'task', :show?
    @task = Task.find(params[:id])
  end
end
