module AdminHelper
  def division_select_options
    [['All', nil]].concat(current_user.accessible_divisions.map{ |d| [d.name, d.id] })
  end
end
