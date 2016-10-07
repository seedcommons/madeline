require 'rails_helper'

RSpec.describe BreakevenTableQuestion, type: :model do
  let(:json) do
    {
      'products': [
        { 'name': 'Product 1', 'description': 'Description', 'unit': 'Widgets', 'price': 100, 'cost': 50, 'quantity': 800 },
        { 'name': 'Product 2', 'description': 'Description', 'unit': 'Stamp books', 'price': 120, 'cost': 60, 'quantity': 300 },
        { 'name': 'Product 3', 'description': 'Description', 'unit': 'Flin Flons', 'price': 150, 'cost': 70, 'quantity': 100 },
      ],
      'fixed_costs': [
        { 'name': 'Rent', 'amount': 1_5000 },
        { 'name': 'Worker owners', 'amount': 28_000.0 },
        { 'name': 'Employees', 'amount': 10_000.0 },
        { 'name': 'Sales', 'amount': 10_000 },
        { 'name': 'Utilities', 'amount': 2_000.0 },
        { 'name': 'Insurance', 'amount': 1_000.0 },
      ],
      'periods': 4,
      'units': 'Months',
    }
  end

  let(:results) do
    {
      revenue: [
        { name: 'Product 1', quantity: 800.0, amount: 100.0, total: 80_000.0 },
        { name: 'Product 2', quantity: 300.0, amount: 120.0, total: 36_000.0 },
        { name: 'Product 3', quantity: 100.0, amount: 150.0, total: 15_000.0 },
      ],
      total_revenue: 131_000,
      cogs: [
        { name: 'Product 1', quantity: 800.0, amount: 50, total: 40_000 },
        { name: 'Product 2', quantity: 300.0, amount: 60, total: 18_000 },
        { name: 'Product 3', quantity: 100, amount: 70, total: 7_000 },
      ],
      total_cogs: 65_000,
      gross_margin: 66_000,
      fixed_costs: [
        { name: 'Rent', amount: 15_000.0 },
        { name: 'Worker owners', amount: 28_000.0 },
        { name: 'Employees', amount: 10_000.0 },
        { name: 'Sales', amount: 10_000 },
        { name: 'Utilities', amount: 2_000.0 },
        { name: 'Insurance', amount: 1_000.0 },
      ],
      total_fixed_costs: 66_000,
      net_margin: 0,
      periods: 4,
      units: 'Months'
    }
  end

  subject { BreakevenTableQuestion.new(json) }

  it 'calculates entire report properly' do
    expect(subject.report).to eq results
  end

  [
    :revenue,
    :total_revenue,
    :cogs,
    :total_cogs,
    :gross_margin,
    :fixed_costs,
    :total_fixed_costs,
    :net_margin,
    :periods,
    :units,
  ].each do |row|
    it "calculates #{row}" do
      expect(subject.report[row]).to eq results[row]
    end
  end
end
