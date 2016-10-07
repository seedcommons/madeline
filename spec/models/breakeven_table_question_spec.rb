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
        { name: 'Product 1', quantity: 800.0, amount: 100.0, total: 80_000.0, rampup: [
          { quantity: 200.0, total: 20_000.0 },
          { quantity: 400.0, total: 40_000.0 },
          { quantity: 600.0, total: 60_000.0 },
          { quantity: 800.0, total: 80_000.0 },
        ] },
        { name: 'Product 2', quantity: 300.0, amount: 120.0, total: 36_000.0, rampup: [
          { quantity: 75.0, total: 9_000.0 },
          { quantity: 150.0, total: 18_000.0 },
          { quantity: 225.0, total: 27_000.0 },
          { quantity: 300.0, total: 36_000.0 },
        ] },
        { name: 'Product 3', quantity: 100.0, amount: 150.0, total: 15_000.0, rampup: [
          { quantity: 25.0, total: 3_750.0 },
          { quantity: 50.0, total: 7_500.0 },
          { quantity: 75.0, total: 11_250.0 },
          { quantity: 100.0, total: 15_000.0 },
        ] },
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

  [1, 2, 3].each do |product_number|
    context "with Product #{product_number}" do
      subject do
        question = BreakevenTableQuestion.new(json)
        question.report[:revenue].find { |p| p[:name] == "Product #{product_number}" }
      end

      let(:expected_product) { results[:revenue].find { |p| p[:name] == "Product #{product_number}" } }

      it "revenue rampup" do
        expect(subject[:rampup]).to eq expected_product[:rampup]
      end
    end
  end
end
