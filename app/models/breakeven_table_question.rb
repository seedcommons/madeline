class BreakevenTableQuestion
  def initialize(breakeven_data)
    @breakeven_data = JSON.parse(breakeven_data) if breakeven_data
  end

  def report
    @breakeven_data
  end
end
