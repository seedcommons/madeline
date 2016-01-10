##
## provides genericized view handling of the various model classes
##
## can scoped to given base namespace and view path (assigned by Helper)
##


#todo: consider base class vs mixin
class BaseCrudController < ApplicationController
  include BaseCrudHelper

  layout 'raw_crud'


  def clazz
    raise "not implemented - clazz"
  end

  # handy switch for the division owned models.
  # should probably be factored out to a concern
  def division_scoped?
    false
  end


  def model_name
    clazz.name
  end

  def models_name
    clazz.name.pluralize
  end

  def model_underscore
    clazz.name.underscore
  end

  def models_underscore
    clazz.name.underscore.pluralize
  end

  def model_sym
    model_underscore.to_sym
  end

  def models_sym
    models_underscore.to_sym
  end


  def set_left_nav_selection
    session[:left_nav_selection] = models_underscore
  end

  # filter and convert submitted edit form params
  def update_attrs
    raise "not implemented - update_attrs"
  end

  # if assigned by sub controller, then use this data for the initial model create and then update as a second step.
  # needed to detail with dependent attributes like translations
  # this should return any data needed to pass validation
  def create_attrs
    []
  end


  DEFAULT_PER_PAGE = 15

  def index
    set_left_nav_selection
    @division_scoped = division_scoped?
    @items = index_items.paginate(page: params[:page], per_page: DEFAULT_PER_PAGE)
    render view_path(models_underscore, "index")
  end

  # by default show all items, but can be overridden for division owned, or otherwise scoped index views
  def index_items
    if division_scoped?
      @items = resolve_division_scoped_index_items
    else
      @items = clazz.all
    end
  end

  # handy for the division owned models.
  # could perhaps be in a different superclass, but that feels to heavy.
  def resolve_division_scoped_index_items
    puts "resolve relation - params: #{params}"
    if params[:all_accessible] == '1'
      method = "accessible_#{clazz.name.downcase.pluralize}".to_sym
    else
      method = clazz.name.downcase.pluralize.to_sym
    end
    current_division.send(method)
  end


  def show
    set_left_nav_selection
    @item = clazz.find(params[:id])
    render view_path(models_underscore, 'show')
  end

  def new
    data = new_query_params
    extra_new_item_params(data)
    @item = clazz.new(data)
    render view_path('common/new')
  end

  # hook to allow automatic division ownership assignment or other contextual data when creating a new record
  def extra_new_item_params(data)
    if division_scoped?
      data[:division_id] = current_division.id
    end
  end


  def create
    # create blank record first to avoid parental issues with translation records
    create_data = create_params
    if create_data.present?
      # the two step create flow
      @item = clazz.create(create_data)
      if @item.valid?
        full_data = update_params
        @item.update(full_data)
        if @item.valid?
          redirect_to item_path(@item)
        else
          # was partially created, display 'edit' form with errors
          render view_path('common/edit')
        end
      else
        # initial save failed, redisplay 'new' form with errors
        render view_path('common/new')
      end
    else
      # the single step create flow
      full_data = update_params
      @item = clazz.create(full_data)
      if @item.valid?
        redirect_to item_path(@item)
      else
        render view_path('common/new')
      end
    end
  end


  def edit
    @item = clazz.find(params[:id])
    render view_path('common/edit')
  end

  def update
    @item = clazz.find(params[:id])

    if @item.update(update_params)
      redirect_to item_path(@item)
    else
      render view_path('common/edit')
    end
  end

  def destroy
    @item = clazz.find(params[:id])
    @item.destroy

    redirect_to index_path
  end


  # full list of attributes which may be assigned from a form
  def update_params
    params.require(model_sym).permit(update_attrs)
  end

  # if a two stage model creations is needed because of dependent attributes, then these are the fields which should be included
  # in the initial create() call.  if empty, then update_params used for a single stage create() call
  def create_params
    params.require(model_sym).permit(create_attrs)
  end

  # new link query params to be applied to a new model
  def new_query_params
    params.permit(create_attrs)
  end


  ##
  ## methods shared as helpers
  ##

  helper_method :model_name, :models_name, :view_path, :resolved_path, :index_path, :item_path, :edit_item_path, :new_item_path, :form_url, :base_view_path

  def base_namespace
    # 'admin/raw/'
    # strip off the last path element to get the base controller path
    controller_path.rpartition('/').first + '/'
  end


  def base_namespace_path
    # 'admin_raw_'
    base_namespace.gsub(/\//, '_')
  end

  # controls which base folder of views to use.
  # could have adapting logic for cases where view folder not aligned with controller namespace
  def base_view_path
    # 'admin/raw/'
    base_namespace
  end


  def resolve_controller(item)
    base_namespace + item.class.name.underscore.pluralize
  end


  # resolves the full path of a view to render
  # head may be parent folder name, model instance, or already combined with tail
  def view_path(head, tail=nil)
    sub_path = head.is_a?(String) ? head : head.class.name.underscore.pluralize
    result = "#{base_view_path}#{sub_path}"
    result = [result, tail].join('/')  if tail
    result
  end


  # resolves the appropriate path helper for the given context
  # name: model name,
  # item: model instance, if provided, then 'name' param unneeded and ignored
  # action: controller action
  # params: hash of query params to include
  def resolved_path(name: nil, item: nil, action: nil, params: nil)
    name = item.class.name.underscore  if item
    name =  name.to_s  if name.is_a? Symbol
    action = action.to_s  if action.is_a? Symbol
    method_name = "#{base_namespace_path}#{name}_path"
    method_name = "#{action}_#{method_name}"  if action
    # if we have both a target item and query params, merge into a single hash
    params[:id] = item.id  if params && item
    params ||= item
    self.send(method_name.to_sym, params)
  end

  def index_path(name=nil, params=nil)
    name ||= models_underscore
    resolved_path(name: name, params: params)
  end

  def item_path(item, params=nil)
    resolved_path(item: item, params: params)
  end

  def edit_item_path(item, params=nil)
    resolved_path(item: item, action: 'edit', params: params)
  end

  def new_item_path(model_name=nil, params = nil)
    model_name ||= model_underscore
    resolved_path(name: model_name, action: :new, params: params)
  end


  def form_url(item)
    action = item.new_record? ? 'create' : 'update'
    url_for(:controller => resolve_controller(item), :action => action)
  end


end
