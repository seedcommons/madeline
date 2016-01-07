##
## provides genericized view handling of the various model classes
##
## can scoped to given base namespace and view path (assigned by Helper)
##


#todo: consider base class vs mixin
class BaseRawCrudController < ApplicationController
  include RawCrudHelper

  layout 'raw_crud'


  #
  # note, this class could still use some better refactoring and cleanup
  #



  def clazz
    raise "not implemented - clazz"
  end

  # handy switch for the division owned models.
  # should probably be factored out to a concern
  def division_scoped?
    false
  end

  def index_path
    resolved_path("#{models_underscore}")
  end

  def new_item_path
    resolved_path(model_underscore, "new")
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
    clazz.name.underscore.to_sym
  end

  def set_left_nav_selection
    session[:left_nav_selection] = models_underscore
  end

  helper_method :index_path, :new_item_path, :item_path, :edit_item_path, :model_name, :models_name, :current_division

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

  def index
    set_left_nav_selection
    @division_scoped = division_scoped?
    @items = index_items.paginate(page: params[:page], per_page: DEFAULT_PER_PAGE)
    resolved_render models_underscore, "index"
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
    resolved_render models_underscore, "show"
  end

  def new
    data = new_query_params
    extra_new_item_params(data)
    @item = clazz.new(data)
    resolved_render "common", "new"
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
          resolved_render 'common', 'edit'
        end
      else
        # initial save failed, redisplay 'new' form with errors
        resolved_render 'common', 'new'
      end
    else
      # the single step create flow
      full_data = update_params
      @item = clazz.create(full_data)
      if @item.valid?
        redirect_to item_path(@item)
      else
        resolved_render 'common', 'new'
      end
    end
  end


  def edit
    @item = clazz.find(params[:id])
    resolved_render 'common', 'edit'
  end

  def update
    @item = clazz.find(params[:id])

    if @item.update(update_params)
      redirect_to item_path(@item)
    else
      resolved_render 'common', 'edit'
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


  DEFAULT_PER_PAGE = 15

end
