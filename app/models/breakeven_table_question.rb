# Performs calculations necessary to produce Breakeven Table Report on loan questions
class BreakevenTableQuestion
  # Expects JSON input like this:
  # {
  #   "products": [
  #     { "name": "Product 1", "description": "Description", "unit": "Widgets", "price": 100, "cost": 50, "quantity": 800 },
  #     { "name": "Product 2", "description": "Description", "unit": "Stamp books", "price": 200, "cost": 75, "quantity": 1000 }
  #   ],
  #   "periods": 4,
  #   "unit": "months",
  #   "fixed_costs": [
  #     { "name": "Rent", "amount": 15000 },
  #     { "name": "Stamps", "amount": 2.25 }
  #   ]
  # }
  def initialize(breakeven)
    @breakeven = breakeven
  end

  # Returns a ruby hash like this:
  # {
  #   revenue: [
  #     { name: 'Product 1', quantity: 800, amount: 100, total: 80_000 },
  #     { name: 'Product 2', quantity: 300, amount: 120, total: 36_000 },
  #     { name: 'Product 3', quantity: 100, amount: 150, total: 15_000 },
  #   ],
  #   revenue_rampup: [
  #     { name: 'Product 1', quantity: 800, amount: 100, total: 80_000 },
  #     { name: 'Product 2', quantity: 300, amount: 120, total: 36_000 },
  #     { name: 'Product 3', quantity: 100, amount: 150, total: 15_000 },
  #   ],
  #   total_revenue: 131_000,
  #   cogs: [
  #     { name: 'Product 1', quantity: 800, amount: 50, total: 40_000 },
  #     { name: 'Product 2', quantity: 300, amount: 60, total: 18_000 },
  #     { name: 'Product 3', quantity: 100, amount: 70, total: 7_000 },
  #   ],
  #   total_cogs: 65_000,
  #   gross_margin: 66_000,
  #   fixed_costs: [
  #     { name: "Rent", amount: 15_000 },
  #     { name: "Worker owners", amount: 28_000 },
  #     { name: "Employees", amount: 10_000 },
  #     { name: "Sales", amount: 10_000 },
  #     { name: "Utilities", amount: 2_000 },
  #     { name: "Insurance", amount: 1_000 },
  #   ],
  #   total_fixed_costs: 66_000,
  #   net_margin: 0,
  # }

  # def rampup_report

  def report
    return if blank?

    report = {
      revenue: revenue,
      total_revenue: total_revenue,
      total_revenue_rampup: total_revenue_rampup,
      cogs: cogs,
      total_cogs: total_cogs,
      total_cogs_rampup: total_cogs_rampup,
      gross_margin: gross_margin,
      gross_margin_rampup: gross_margin_rampup,
      fixed_costs: fixed_costs,
      total_fixed_costs: total_fixed_costs,
      total_fixed_costs_rampup: total_fixed_costs_rampup,
      net_margin: net_margin,
      periods: periods,
      units: units,
    }

    report
  end

  def blank?
    return true if @breakeven.blank?
    data_hash[:products].blank? && data_hash[:fixed_costs].blank?
  end

  def revenue
    data_hash[:products].map do |product|
      [:quantity, :price, :cost].map { |key| product[key] = product[key].to_f }
        {
          name: product[:name],
          quantity: product[:quantity],
          amount: product[:price],
          total: product[:price] * product[:quantity],
          rampup: rampup(product[:quantity], product[:price])
        }
    end
  end

  def total_revenue
    revenue.map { |i| i[:total] }.sum
  end

  def total_revenue_rampup
    (1..periods).map do |period|
      (total_revenue/periods) * period
    end
  end

  def cogs
    data_hash[:products].map do |product|
      [:quantity, :price, :cost].map { |key| product[key] = product[key].to_f }
        {
          name: product[:name],
          quantity: product[:quantity],
          amount: product[:cost],
          total: product[:cost] * product[:quantity],
          rampup: rampup(product[:quantity], product[:cost])
        }
    end
  end

  def total_cogs
    cogs.map { |i| i[:total] }.sum
  end

  def total_cogs_rampup
    (1..periods).map do |period|
      (total_cogs/periods) * period
    end
  end

  def gross_margin
    total_revenue - total_cogs
  end

  def gross_margin_rampup
    (1..periods).map do |period|
      (gross_margin/periods) * period
    end
  end

  def fixed_costs
    data_hash[:fixed_costs].map do |cost|
      { name: cost[:name], amount: cost[:amount].to_f }
    end
  end

  def total_fixed_costs
    fixed_costs.map { |i| i[:amount] }.sum
  end

  def total_fixed_costs_rampup
    (1..periods).map do |period|
      total_fixed_costs
    end
  end

  def net_margin
    gross_margin - total_fixed_costs
  end

  def data_hash
    @breakeven.deep_symbolize_keys if @breakeven
  end

  def periods
    data_hash[:periods]
  end

  def units
    data_hash[:units]
  end

  def rampup(total_quantity, price)
    (1..periods).map do |period|
      base_quantity = total_quantity / periods
      quantity = (base_quantity * period)
      total = quantity * price

      { quantity: quantity, total: total }
    end
  end
end
