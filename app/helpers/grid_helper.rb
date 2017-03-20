module GridHelper
  def render_index_grid(grid)
    render "admin/common/grid", grid: grid
  end

  # This is a hack that sets an instance variable indicating no
  # records at all in the DB for a given grid, as opposed to no records matching the filter.
  # Called from the `blank_slate` WiceGrid property.
  # Returns empty string because WiceGrid wants something to render if there are no records,
  # but we render our stuff elsewhere.
  def set_no_grid_records_flag
    @no_records_at_all = true
    ""
  end
end
