class BreakevenTableQuestion
  def initialize(breakeven_data)
    @breakeven_data = JSON.parse(breakeven_data) if breakeven_data.present?
  end

  def report
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
end
