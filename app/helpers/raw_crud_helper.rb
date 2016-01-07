module RawCrudHelper


  #
  # note, this class could still use some better refactoring and cleanup
  #


  def namespace_path_prefix
    'admin_'
  end

  def view_path_prefix
    'admin/raw/'
  end


  def resolved_render(parent, path, param=nil)
    parent_folder = parent.is_a?(String) ? parent : parent.class.name.underscore.pluralize
    resolved_path = "#{view_path_prefix}/#{parent_folder}/#{path}"
    if param
      render resolved_path, param
    else
      render resolved_path
    end

  end



  ## todo: used named params & allow model instead of name
  def resolved_path(name, action=nil, param=nil)
    method_name = "#{namespace_path_prefix}#{name}_path"
    method_name = "#{action}_#{method_name}"  if action
    self.send(method_name.to_sym, param)
  end


  def item_path(item)
    resolved_path(item.class.name.underscore, nil, item)
  end



  def edit_item_path(item)
    resolved_path(item.class.name.underscore, "edit", item)
  end



  def render_index_header
    # render view_path_prefix + 'common/index_header'
    resolved_render 'common', 'index_header'
  end

  def render_show_header
    # render view_path_prefix + 'common/show_header'
    resolved_render 'common', 'show_header'
  end

  def resolve_controller(item)
    'admin/'+item.class.name.underscore.pluralize
  end

  def form_url(item)
    action = item.new_record? ? 'create' : 'update'
    url_for(:controller => resolve_controller(item), :action => action)
  end

  def organizations_path
    resolved_path("organizations")
  end

  def loans_path
    resolved_path("loans")
  end

  def people_path
    resolved_path("people")
  end

  def divisions_path
    resolved_path("divisions")
  end

  DEFAULT_LEFT_NAV_SELECTION = 'loans'

  def left_nav_selection
    selection = session[:left_nav_selection]
    unless selection
      selection = DEFAULT_LEFT_NAV_SELECTION
      session[:left_nav_selection] = selection
    end
    selection
  end

  def selected_nav_path
    # self.send("#{left_nav_selection}_path".to_sym)
    resolved_path(left_nav_selection)
  end



  def current_division
    logger.debug "current_division - params: #{params}"
    if params[:set_division_id]
      set_current_division_id(params[:set_division_id])
    end
    division_id = current_division_id
    division = Division.find_safe(division_id)
    unless division
      logger.warn "current_division_id: #{division_id} not found - resetting"
      session[:current_division_id] = nil
      division_id = current_division_id
      division = Division.find_safe(division_id)
      logger.error "unexpectedly unable to find default division id: #{division_id}"
    end
    division
  end

  def current_division_id
    unless session[:current_division_id]
      logger.info "new session - assigning default div id"
      division_id = default_division_id
      session[:current_division_id] = division_id
    end
    session[:current_division_id]
  end

  def default_division_id
    # todo: better default logic
    division_id = Division.first.id
  end

  def set_current_division_id(id)
    session[:current_division_id] = id
  end

  def division_select_data
    Division.all.map{|d| [d.name, d.id]}  #todo: cache this
  end

  def organization_select_options(selected)
    options_from_collection_for_select(current_division.accessible_organizations, :id, :name, selected)
  end

  def person_select_options(selected)
    options_from_collection_for_select(current_division.accessible_people, :id, :name, selected)
  end

  def country_select_options(selected)
    options_from_collection_for_select(Country.all, :id, :name, selected)
  end

  #todo: figure out if i can omit the model param since the form should already have a reference
  def select_country(form, model, name = 'country_id'.to_sym)
    form.select(name, country_select_options(model.send(name)), {include_blank: '---'})
  end

  def division_select_options(selected)
    options_from_collection_for_select(Division.all, :id, :name, selected)
  end

  def select_division(form, model, name = 'division_id'.to_sym)
    form.select(name, division_select_options(model.send(name)), {include_blank: '---'})
  end




end
