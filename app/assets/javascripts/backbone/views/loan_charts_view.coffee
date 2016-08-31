class MS.Views.LoanChartsView extends Backbone.View

  el: '.summary-chart'

  initialize: (params) ->
    @breakevenData = params.breakeven_data
    @breakevenFixedCosts = @breakevenData["fixed_costs"]
    @breakevenProductionCosts = @breakevenData["cogs"]
    @breakevenRevenue = @breakevenData["revenue"]

    @loadCharts()

  breakevenFixedCostsChart: () ->
    chartData = {}
    columns = [
      {"id":"","label":I18n.t('loan.breakeven.fixed_costs', count: 1),"pattern":"","type":"string"},
      {"id":"","label":I18n.t('loan.breakeven.amount'),"pattern":"","type":"number"}
    ]

    rows = []
    for key,cost of @breakevenFixedCosts
      name = cost.name
      total = cost.amount
      rows.push({"c":[{"v": name, "f":null},{"v": total, "f":null}]})

    options = {
      width: 400,
      height: 240,
      title: I18n.t('loan.breakeven.fixed_costs', count: 2)
    }
    chartData = {"cols": columns, "rows": rows}
    chartData = new google.visualization.DataTable(chartData);
    chart = new google.visualization.PieChart(document.getElementById('breakeven-fixed-cost-chart'));
    chart.draw(chartData, options);

  breakevenProductProfitChart: () ->
    chartData = {}
    columns = [
      {"id":"","label":I18n.t('loan.breakeven.product'),"pattern":"","type":"string"},
      {"id":"","label":I18n.t('loan.breakeven.profit'),"pattern":"","type":"number"}
    ]

    rows = []
    for key,product of @breakevenProductProfit()
      name = key
      total = product.profit
      rows.push({"c":[{"v": name, "f":null},{"v": total, "f":null}]})

    options = {
      width: 400,
      height: 240,
      title: I18n.t('loan.breakeven.profit_by_product')
    }
    chartData = {"cols": columns, "rows": rows}
    chartData = new google.visualization.DataTable(chartData);
    chart = new google.visualization.PieChart(document.getElementById('breakeven-product-profit'));
    chart.draw(chartData, options);

  breakevenProductionCostsChart: () ->
    chartData = {}
    columns = [
      {"id":"","label":I18n.t('loan.breakeven.product'),"pattern":"","type":"string"},
      {"id":"","label":I18n.t('loan.breakeven.production_cost'),"pattern":"","type":"number"}
    ]

    options = {
      width: 400,
      height: 240,
      title: I18n.t('loan.breakeven.production_cost_by_product')
    }

    rows = []
    for key,product of @breakevenProductionCosts
      name = product.name
      total = product.total
      rows.push({"c":[{"v": name, "f":null},{"v": total, "f":null}]})

    chartData = {"cols": columns, "rows": rows}
    chartData = new google.visualization.DataTable(chartData);
    chart = new google.visualization.PieChart(document.getElementById('breakeven-production-cost-chart'));
    chart.draw(chartData, options);

  breakevenProductProfit: () ->
    profitData = {}

    for key,product of @breakevenRevenue
      name = product.name
      revenue = product.total

      profitData[name] = {revenue: revenue}

    for key,product of @breakevenProductionCosts
      name = product.name
      cost = product.total

      profitData[name]['cost'] = cost
      profitData[name]['profit'] = profitData[name]['revenue'] - cost

    return profitData

  breakevenRevenueChart: () ->
    chartData = {}
    columns = [
      {"id":"","label":I18n.t('loan.breakeven.product'),"pattern":"","type":"string"},
      {"id":"","label":I18n.t('loan.breakeven.revenue'),"pattern":"","type":"number"}
    ]

    options = {
      width: 400,
      height: 240,
      title: I18n.t('loan.breakeven.revenue_by_product')
    }
    rows = []
    for key,product of @breakevenRevenue
      name = product.name
      total = product.total
      rows.push({"c":[{"v": name, "f":null},{"v": total, "f":null}]})

    chartData = {"cols": columns, "rows": rows}
    chartData = new google.visualization.DataTable(chartData);
    chart = new google.visualization.PieChart(document.getElementById('breakeven-revenue-chart'));
    chart.draw(chartData, options);

  breakevenTotalCostsChart: () ->
    chartData = {}
    columns = [
      {"id":"","label":I18n.t('loan.breakeven.item'),"pattern":"","type":"string"},
      {"id":"","label":I18n.t('loan.breakeven.cost'),"pattern":"","type":"number"}
    ]
    rows = []

    for key,product of @breakevenProductionCosts
      name = product.name
      total = product.total
      rows.push({"c":[{"v": name, "f":null},{"v": total, "f":null}]})

    for key,cost of @breakevenFixedCosts
      name = cost.name
      total = cost.amount
      rows.push({"c":[{"v": name, "f":null},{"v": total, "f":null}]})

    options = {
      width: 400,
      height: 240,
      title: I18n.t('loan.breakeven.total_cost_breakdown')
    }
    slices = {}

    # Color is adjusted per item based on total items in a specific group
    # Fixed costs have a different base color than product costs
    productionCostLength = @breakevenProductionCosts.length
    fixedCostLength = rows.length - productionCostLength
    productionIncrement = parseInt(255/productionCostLength)
    fixedCostIncrement = parseInt(255/fixedCostLength)

    i = 0
    for key,row of rows
      if key < productionCostLength
        slices[parseInt(key)] = {color:
          "rgb(#{0 + (productionIncrement * parseInt(key))},
          #{0 + (productionIncrement * parseInt(key))},
          255)"
        }
      else
        slices[parseInt(key)] = {color:
          "rgb(255,
          #{0 + (fixedCostIncrement * i)},
          #{0 + (fixedCostIncrement * i)})"
        }
        ++i

    options.slices = slices
    chartData = {"cols": columns, "rows": rows}
    chartData = new google.visualization.DataTable(chartData)
    chart = new google.visualization.PieChart(document.getElementById('breakeven-total-costs-chart'))
    chart.draw(chartData, options);

  loadCharts: () ->
    google.charts.load('current', {'packages':['corechart']});
    google.charts.setOnLoadCallback @breakevenRevenueChart.bind @
    google.charts.setOnLoadCallback @breakevenProductionCostsChart.bind @
    google.charts.setOnLoadCallback @breakevenFixedCostsChart.bind @
    google.charts.setOnLoadCallback @breakevenProductProfitChart.bind @
    google.charts.setOnLoadCallback @breakevenTotalCostsChart.bind @
