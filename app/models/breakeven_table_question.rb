# Performs calculations necessary to produce Breakeven Table Report on loan questions
class BreakevenTableQuestion
  # Expects JSON input like this:
  # {
  #   'products': [
  #     { 'name': 'Product 1', 'description': 'Description', 'unit': 'Widgets', 'price': 100, 'cost': 50, 'quantity': 800 },
  #     { 'name': 'Product 2', 'description': 'Description', 'unit': 'Stamp books', 'price': 120, 'cost': 60, 'quantity': 300 },
  #     { 'name': 'Product 3', 'description': 'Description', 'unit': 'Flin Flons', 'price': 150, 'cost': 70, 'quantity': 100 },
  #   ],
  #   'fixed_costs': [
  #     { 'name': 'Rent', 'amount': 1_5000 },
  #     { 'name': 'Worker owners', 'amount': 28_000.0 },
  #     { 'name': 'Employees', 'amount': 10_000.0 },
  #     { 'name': 'Sales', 'amount': 10_000 },
  #     { 'name': 'Utilities', 'amount': 2_000.0 },
  #     { 'name': 'Insurance', 'amount': 1_000.0 },
  #   ],
  #   'periods': 4,
  #   'units': 'Months',
  # }
  def initialize(breakeven)
    @breakeven = breakeven
  end

  # Returns a ruby hash like this:
  # {
  #   revenue: [
  #     { name: 'Product 1', quantity: 800.0, amount: 100.0, total: 80_000.0, rampup: [
  #       { quantity: 200.0, total: 20_000.0 },
  #       { quantity: 400.0, total: 40_000.0 },
  #       { quantity: 600.0, total: 60_000.0 },
  #       { quantity: 800.0, total: 80_000.0 },
  #     ] },
  #     { name: 'Product 2', quantity: 300.0, amount: 120.0, total: 36_000.0, rampup: [
  #       { quantity: 75.0, total: 9_000.0 },
  #       { quantity: 150.0, total: 18_000.0 },
  #       { quantity: 225.0, total: 27_000.0 },
  #       { quantity: 300.0, total: 36_000.0 },
  #     ] },
  #     { name: 'Product 3', quantity: 100.0, amount: 150.0, total: 15_000.0, rampup: [
  #       { quantity: 25.0, total: 3_750.0 },
  #       { quantity: 50.0, total: 7_500.0 },
  #       { quantity: 75.0, total: 11_250.0 },
  #       { quantity: 100.0, total: 15_000.0 },
  #     ] },
  #   ],
  #   total_revenue: 131_000,
  #   total_revenue_rampup: [3_2750, 65_500, 98_250, 131_000],
  #   cogs: [
  #     { name: 'Product 1', quantity: 800.0, amount: 50.0, total: 40_000.0, rampup: [
  #       { quantity: 200.0, total: 10_000.0 },
  #       { quantity: 400.0, total: 20_000.0 },
  #       { quantity: 600.0, total: 30_000.0 },
  #       { quantity: 800.0, total: 40_000.0 },
  #     ] },
  #     { name: 'Product 2', quantity: 300.0, amount: 60.0, total: 18_000.0, rampup: [
  #       { quantity: 75.0, total: 4_500.0 },
  #       { quantity: 150.0, total: 9_000.0 },
  #       { quantity: 225.0, total: 13_500.0 },
  #       { quantity: 300.0, total: 18_000.0 },
  #     ] },
  #     { name: 'Product 3', quantity: 100.0, amount: 70.0, total: 7_000.0, rampup: [
  #       { quantity: 25.0, total: 1_750.0 },
  #       { quantity: 50.0, total: 3_500.0 },
  #       { quantity: 75.0, total: 5_250.0 },
  #       { quantity: 100.0, total: 7_000.0 },
  #     ] },
  #   ],
  #   total_cogs: 65_000,
  #   total_cogs_rampup: [16_250, 32_500, 48_750, 65_000],
  #   gross_margin: 66_000,
  #   gross_margin_rampup: [16_500, 33_000, 49_500, 66_000],
  #   fixed_costs: [
  #     { name: 'Rent', amount: 15_000.0 },
  #     { name: 'Worker owners', amount: 28_000.0 },
  #     { name: 'Employees', amount: 10_000.0 },
  #     { name: 'Sales', amount: 10_000 },
  #     { name: 'Utilities', amount: 2_000.0 },
  #     { name: 'Insurance', amount: 1_000.0 },
  #   ],
  #   total_fixed_costs: 66_000,
  #   total_fixed_costs_rampup: [66_000, 66_000, 66_000, 66_000],
  #   net_margin: 0,
  #   net_margin_rampup: [-49_500, -33_000, -16_500, 0],
  #   periods: 4,
  #   units: 'Months'
  # }
  def report
    return if blank?

    return report_hash unless periods > 1
    report_hash.merge(rampup_hash)
  end

  def blank?
    return true if @breakeven.blank?
    data_hash[:products].blank? && data_hash[:fixed_costs].blank?
  end

  private

  def report_hash
    {
      revenue: revenue,
      total_revenue: total_revenue,
      cogs: cogs,
      total_cogs: total_cogs,
      gross_margin: gross_margin,
      fixed_costs: fixed_costs,
      total_fixed_costs: total_fixed_costs,
      net_margin: net_margin,
      periods: periods,
      units: units,
    }
  end

  def rampup_hash
    {
      total_revenue_rampup: total_revenue_rampup,
      total_cogs_rampup: total_cogs_rampup,
      gross_margin_rampup: gross_margin_rampup,
      total_fixed_costs_rampup: total_fixed_costs_rampup,
      net_margin_rampup: net_margin_rampup,
    }
  end

  def calculate_line_item_totals(total_key)
    data_hash[:products].map do |product|
      next unless product.present? && product[:name].present?
      {
        name: product[:name],
        quantity: product.fetch(:quantity, 0),
        amount: product.fetch(total_key, 0),
        total: product.fetch(total_key, 0) * product.fetch(:quantity, 0),
      }.merge(rampup(product[:quantity], product[total_key]))
    end.compact
  end

  def revenue
    @revenue ||= calculate_line_item_totals(:price)
  end

  def total_revenue
    @total_revenue ||= revenue.sum { |i| i[:total] }
  end

  def total_revenue_rampup
    @total_revenue_rampup ||= (1..periods).map do |period|
      (total_revenue / periods) * period
    end
  end

  def cogs
    @cogs ||= calculate_line_item_totals(:cost)
  end

  def total_cogs
    @total_cogs ||= cogs.sum { |i| i[:total] }
  end

  def total_cogs_rampup
    @total_cogs_rampup ||= (1..periods).map do |period|
      (total_cogs / periods) * period
    end
  end

  def gross_margin
    total_revenue - total_cogs
  end

  def gross_margin_rampup
    @gross_margin_rampup ||= (1..periods).map do |period|
      (gross_margin / periods) * period
    end
  end

  def fixed_costs
    return [] unless data_hash[:fixed_costs]
    @fixed_costs ||= data_hash[:fixed_costs].map do |cost|
      next unless cost.present? && cost[:name].present?
      { name: cost[:name], amount: cost[:amount].to_f }
    end.compact
  end

  def total_fixed_costs
    @total_fixed_costs ||= fixed_costs.sum { |i| i[:amount] }
  end

  def total_fixed_costs_rampup
    [total_fixed_costs] * periods
  end

  def net_margin
    gross_margin - total_fixed_costs
  end

  def net_margin_rampup
    (1..periods).map do |period|
      gross_margin_rampup[period - 1] - total_fixed_costs
    end
  end

  def data_hash
    @breakeven.deep_symbolize_keys if @breakeven
  end

  def periods
    data_hash[:periods] || 1
  end

  def units
    data_hash[:units] || 'None'
  end

  def rampup(total_quantity, price)
    return {} unless periods > 1

    rampup = (1..periods).map do |period|
      base_quantity = total_quantity / periods
      quantity = base_quantity * period
      total = quantity * price

      { quantity: quantity, total: total }
    end

    { rampup: rampup }
  end
end
