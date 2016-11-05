require 'rails_helper'

RSpec.describe BreakevenTableQuestion, type: :model do
  report_headings = [
    :revenue,
    :total_revenue,
    :total_revenue_rampup,
    :cogs,
    :total_cogs,
    :total_cogs_rampup,
    :gross_margin,
    :gross_margin_rampup,
    :fixed_costs,
    :total_fixed_costs,
    :total_fixed_costs_rampup,
    :net_margin,
    :net_margin_rampup,
    :periods,
    :units,
  ]

  rampup_headings = [
    :gross_margin_rampup,
    :net_margin_rampup,
    :total_cogs_rampup,
    :total_fixed_costs_rampup,
    :total_revenue_rampup
  ]

  context 'with 4 periods' do
    let(:json) do
      {
        'products': [
          { 'name': 'Product 1', 'description': 'Description', 'unit': 'Widgets', 'price': 100, 'cost': 50, 'quantity': 800 },
          { 'name': 'Product 2', 'description': 'Description', 'unit': 'Stamp books', 'price': 120, 'cost': 60, 'quantity': 300 },
          { 'name': 'Product 3', 'description': 'Description', 'unit': 'Flin Flons', 'price': 150, 'cost': 70, 'quantity': 100 },
        ],
        'fixed_costs': [
          { 'name': 'Rent', 'amount': 15_000 },
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
        total_revenue_rampup: [32_750, 65_500, 98_250, 131_000],
        cogs: [
          { name: 'Product 1', quantity: 800.0, amount: 50.0, total: 40_000.0, rampup: [
            { quantity: 200.0, total: 10_000.0 },
            { quantity: 400.0, total: 20_000.0 },
            { quantity: 600.0, total: 30_000.0 },
            { quantity: 800.0, total: 40_000.0 },
          ] },
          { name: 'Product 2', quantity: 300.0, amount: 60.0, total: 18_000.0, rampup: [
            { quantity: 75.0, total: 4_500.0 },
            { quantity: 150.0, total: 9_000.0 },
            { quantity: 225.0, total: 13_500.0 },
            { quantity: 300.0, total: 18_000.0 },
          ] },
          { name: 'Product 3', quantity: 100.0, amount: 70.0, total: 7_000.0, rampup: [
            { quantity: 25.0, total: 1_750.0 },
            { quantity: 50.0, total: 3_500.0 },
            { quantity: 75.0, total: 5_250.0 },
            { quantity: 100.0, total: 7_000.0 },
          ] },
        ],
        total_cogs: 65_000,
        total_cogs_rampup: [16_250, 32_500, 48_750, 65_000],
        gross_margin: 66_000,
        gross_margin_rampup: [16_500, 33_000, 49_500, 66_000],
        fixed_costs: [
          { name: 'Rent', amount: 15_000.0 },
          { name: 'Worker owners', amount: 28_000.0 },
          { name: 'Employees', amount: 10_000.0 },
          { name: 'Sales', amount: 10_000 },
          { name: 'Utilities', amount: 2_000.0 },
          { name: 'Insurance', amount: 1_000.0 },
        ],
        total_fixed_costs: 66_000,
        total_fixed_costs_rampup: [66_000, 66_000, 66_000, 66_000],
        net_margin: 0,
        net_margin_rampup: [-49_500, -33_000, -16_500, 0],
        periods: 4,
        units: 'Months'
      }
    end

    subject { BreakevenTableQuestion.new(json) }

    it 'does not include extra report headings' do
      expect(subject.report.keys).to match_array report_headings
    end

    report_headings.each do |row|
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

        it 'revenue rampup' do
          expect(subject[:rampup]).to eq expected_product[:rampup]
        end
      end
    end
  end

  context 'with 4 periods and string data' do
    let(:json) do
      {
        'products': [
          { 'name': 'Product 1', 'description': 'Description', 'unit': 'Widgets', 'price': '100', 'cost': '50', 'quantity': '800' },
        ],
        'fixed_costs': [
          { 'name': 'Rent', 'amount': '15000' },
        ],
        'periods': '4',
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
        ],
        total_revenue: 80_000,
        total_revenue_rampup: [20000.0, 40000.0, 60000.0, 80000.0],
        cogs: [
          { name: 'Product 1', quantity: 800.0, amount: 50.0, total: 40_000.0, rampup: [
            { quantity: 200.0, total: 10_000.0 },
            { quantity: 400.0, total: 20_000.0 },
            { quantity: 600.0, total: 30_000.0 },
            { quantity: 800.0, total: 40_000.0 },
          ] },
        ],
        total_cogs: 40_000,
        total_cogs_rampup: [10000.0, 20000.0, 30000.0, 40000.0],
        gross_margin: 40_000,
        gross_margin_rampup: [10000.0, 20000.0, 30000.0, 40000.0],
        fixed_costs: [
          { name: 'Rent', amount: 15_000.0 },
        ],
        total_fixed_costs: 15_000,
        total_fixed_costs_rampup: [15000.0, 15000.0, 15000.0, 15000.0],
        net_margin: 25_000,
        net_margin_rampup: [-5000.0, 5000.0, 15000.0, 25000.0],
        periods: 4,
        units: 'Months'
      }
    end

    subject { BreakevenTableQuestion.new(json) }

    it 'does not include extra report headings' do
      expect(subject.report.keys).to match_array report_headings
    end

    report_headings.each do |row|
      it "calculates #{row}" do
        expect(subject.report[row]).to eq results[row]
      end
    end

    [1].each do |product_number|
      context "with Product #{product_number}" do
        subject do
          question = BreakevenTableQuestion.new(json)
          question.report[:revenue].find { |p| p[:name] == "Product #{product_number}" }
        end

        let(:expected_product) { results[:revenue].find { |p| p[:name] == "Product #{product_number}" } }

        it 'revenue rampup' do
          expect(subject[:rampup]).to eq expected_product[:rampup]
        end
      end
    end
  end

  context 'without periods' do
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
      }
    end

    let(:results) do
      {
        revenue: [
          { name: 'Product 1', quantity: 800.0, amount: 100.0, total: 80_000.0 },
          { name: 'Product 2', quantity: 300.0, amount: 120.0, total: 36_000.0 },
          { name: 'Product 3', quantity: 100.0, amount: 150.0, total: 15_000.0 },
        ],
        total_revenue: 131_000.0,
        cogs: [
          { name: 'Product 1', quantity: 800.0, amount: 50.0, total: 40_000.0 },
          { name: 'Product 2', quantity: 300.0, amount: 60.0, total: 18_000.0 },
          { name: 'Product 3', quantity: 100.0, amount: 70.0, total: 7_000.0 },
        ],
        total_cogs: 65_000.0,
        gross_margin: 66_000.0,
        fixed_costs: [
          { name: 'Rent', amount: 15_000.0 },
          { name: 'Worker owners', amount: 28_000.0 },
          { name: 'Employees', amount: 10_000.0 },
          { name: 'Sales', amount: 10_000 },
          { name: 'Utilities', amount: 2_000.0 },
          { name: 'Insurance', amount: 1_000.0 },
        ],
        total_fixed_costs: 66_000.0,
        net_margin: 0.0,
        periods: 1,
        units: 'Periods'
      }
    end

    subject { BreakevenTableQuestion.new(json) }

    it 'does not include extra report headings' do
      report_headings_without_rampup = report_headings - rampup_headings
      expect(subject.report.keys).to match_array report_headings_without_rampup
    end

    report_headings.each do |row|
      it "calculates #{row}" do
        expect(subject.report[row]).to eq results[row]
      end
    end
  end

  context 'and a products and fixed_costs are incorrectly formatted' do
    let(:json) do
      {
        'products': [
          { 'name': 'Product 1', 'description': 'Description', 'unit': 'Widgets', 'cost': 50, 'quantity': 800 },
          { 'name': 'Product 2', 'description': 'Description' },
          {},
        ],
        'fixed_costs': [
          { 'name': 'Rent', 'amount': 15_000 },
          { 'name': 'Worker owners' },
          {},
        ],
      }
    end

    let(:results) do
      {
        revenue: [
          { name: 'Product 1', quantity: 800.0, amount: 0, total: 0 },
          { name: 'Product 2', quantity: 0, amount: 0, total: 0 },
        ],
        total_revenue: 0,
        cogs: [
          { name: 'Product 1', quantity: 800.0, amount: 50.0, total: 40_000.0 },
          { name: 'Product 2', quantity: 0, amount: 0, total: 0 },
        ],
        total_cogs: 40_000.0,
        gross_margin: -40_000.0,
        fixed_costs: [
          { name: 'Rent', amount: 15_000.0 },
          { name: 'Worker owners', amount: 0 },
        ],
        total_fixed_costs: 15_000,
        net_margin: -55_000.0,
        periods: 1,
        units: 'Periods'
      }
    end

    subject { BreakevenTableQuestion.new(json) }

    report_headings.each do |row|
      it "calculates #{row}" do
        expect(subject.report[row]).to eq results[row]
      end
    end
  end

  context 'without fixed_costs' do
    let(:json) do
      {
        'products': [
          { 'name': 'Product 1', 'description': 'Description', 'unit': 'Widgets', 'price': 100, 'cost': 50, 'quantity': 800 },
          { 'name': 'Product 2', 'description': 'Description', 'unit': 'Stamp books', 'price': 120, 'cost': 60, 'quantity': 300 },
          { 'name': 'Product 3', 'description': 'Description', 'unit': 'Flin Flons', 'price': 150, 'cost': 70, 'quantity': 100 },
        ],
      }
    end

    let(:results) do
      {
        revenue: [
          { name: 'Product 1', quantity: 800.0, amount: 100.0, total: 80_000.0 },
          { name: 'Product 2', quantity: 300.0, amount: 120.0, total: 36_000.0 },
          { name: 'Product 3', quantity: 100.0, amount: 150.0, total: 15_000.0 },
        ],
        total_revenue: 131_000.0,
        cogs: [
          { name: 'Product 1', quantity: 800.0, amount: 50.0, total: 40_000.0 },
          { name: 'Product 2', quantity: 300.0, amount: 60.0, total: 18_000.0 },
          { name: 'Product 3', quantity: 100.0, amount: 70.0, total: 7_000.0 },
        ],
        total_cogs: 65_000.0,
        gross_margin: 66_000.0,
        fixed_costs: [
        ],
        total_fixed_costs: 0,
        net_margin: 66_000.0,
        periods: 1,
        units: 'Periods'
      }
    end

    subject { BreakevenTableQuestion.new(json) }

    it 'does not include extra report headings' do
      report_headings_without_rampup = report_headings - rampup_headings
      expect(subject.report.keys).to match_array report_headings_without_rampup
    end

    report_headings.each do |row|
      it "calculates #{row}" do
        expect(subject.report[row]).to eq results[row]
      end
    end
  end

  context 'with empty products' do
    let(:json) do
      {
        'products': [],
      }
    end

    subject { BreakevenTableQuestion.new(json) }

    it 'returns nil report' do
      expect(subject.report).to be_nil
    end
  end

  context 'with empty json' do
    let(:json) do
      {}
    end

    subject { BreakevenTableQuestion.new(json) }

    it 'returns nil report' do
      expect(subject.report).to be_nil
    end
  end
end
