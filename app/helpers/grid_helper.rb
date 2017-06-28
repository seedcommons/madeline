module GridHelper
  def render_index_grid(grid)
    render "admin/common/grid", grid: grid
  end
end
