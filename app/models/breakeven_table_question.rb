# Performs calculations necessary to produce Breakeven Table Report on loan questions
class BreakevenTableQuestion
  # Expects JSON input like this:
  # {
  #   "products": [
  #     { "name": "Product 1", "description": "Description", "unit": "Widgets", "price": 100, "cost": 50, "quantity": 800 },
  #     { "name": "Product 2", "description": "Description", "unit": "Stamp books", "price": 200, "cost": 75, "quantity": 1000 }
  #   ],
  #   "fixed_costs": [
  #     { "name": "Rent", "amount": 15000 },
  #     { "name": "Stamps", "amount": 2.25 }
  #   ]
  # }
  def initialize(breakeven_data)
    @breakeven_data = JSON.parse(breakeven_data) if breakeven_data.present?
  end

  # Returns a ruby hash like this:
  # {
  #   revenue: [
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
  def report
    return if blank?

    report = {
      revenue: [],
      total_revenue: 0,
      cogs: [],
      total_cogs: 0,
      gross_margin: 0,
      fixed_costs: [],
      total_fixed_costs: 0,
      net_margin: 0,
    }

    @breakeven_data['products'].each do |product|
      %w(quantity price cost).each { |key| product[key] = 0 if product[key].blank? }
      report[:revenue] << {
        name: product['name'],
        quantity: product['quantity'],
        amount: product['price'],
        total: product['price'] * product['quantity'],
      }
      report[:cogs] << {
        name: product['name'],
        quantity: product['quantity'],
        amount: product['cost'],
        total: product['cost'] * product['quantity'],
      }
    end
    report[:total_revenue] = report[:revenue].map { |i| i[:total] }.sum
    report[:total_cogs] = report[:cogs].map { |i| i[:total] }.sum
    report[:gross_margin] = report[:total_revenue] - report[:total_cogs]
    report[:fixed_costs] = @breakeven_data['fixed_costs'].map(&:symbolize_keys)
    report[:total_fixed_costs] = report[:fixed_costs].map { |i| i[:amount] }.sum
    report[:net_margin] = report[:gross_margin] - report[:total_fixed_costs]

    report
  end

  def blank?
    return true if !@breakeven_data
    @breakeven_data['products'].blank? && @breakeven_data['fixed_costs'].blank?
  end
end
