# These functions exist solely for wice_grid.
# wice_grid does not support default filter values. So instead we are overriding the
# params passed to the routes using wice_grid
module NamedRouteOverridesHelper
  def admin_loans_path(*args)
    # Default to active loans, unless overriden
    options = HashWithIndifferentAccess.new loans: {f:{status_value: ['active']}}
    options = options.deep_merge(args.pop) if args.last.is_a? Hash

    super(args, options)
  end

  def admin_people_path(*args)
    # Default to system users, unless overriden
    options = HashWithIndifferentAccess.new people: {f:{ has_system_access: ['t']}}
    options = options.deep_merge(args.pop) if args.last.is_a? Hash

    super(args, options)
  end
end
