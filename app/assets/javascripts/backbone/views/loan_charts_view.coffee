class MS.Views.LoanChartsView extends Backbone.View

  initialize: (params) ->
    @breakevenData = params.breakeven_data
    @breakevenFixedCosts = @breakevenData["fixed_costs"]
    @breakevenProductionCosts = @breakevenData["cogs"]
    @breakevenRevenue = @breakevenData["revenue"]
    @defaultChartOptions = {
      height: 200,
      width: '100%',
      chartArea: {
        left: 0,
        top: 10,
        width: '100%',
        height: '90%'
      },
      backgroundColor: 'none'
    }
    @loadCharts()
    google.charts.load('current', {'packages':['corechart']});

  loadCharts: ->
    google.charts.setOnLoadCallback @breakevenRevenueChart.bind @
    google.charts.setOnLoadCallback @breakevenProductionCostsChart.bind @
    google.charts.setOnLoadCallback @breakevenProductProfitChart.bind @
    google.charts.setOnLoadCallback @breakevenFixedCostsChart.bind @
    google.charts.setOnLoadCallback @breakevenCostsChart.bind @

  breakevenRevenueChart: ->
    chartTable = @defaultChartTable(I18n.t('loan.breakeven.product'), I18n.t('loan.breakeven.revenue'), @breakevenRevenue)
    @drawPieChartIntoElement('.breakeven-revenue-chart', chartTable)

  breakevenProductionCostsChart: ->
    chartTable = @defaultChartTable(I18n.t('loan.breakeven.product'), I18n.t('loan.breakeven.production_cost'), @breakevenProductionCosts)
    @drawPieChartIntoElement('.breakeven-production-cost-chart', chartTable)

  breakevenProductProfitChart: ->
    @drawPieChartIntoElement('.breakeven-product-profit-chart', @breakevenProductProfit())

  breakevenFixedCostsChart: ->
    data = new google.visualization.DataTable()
    data.addColumn 'string', I18n.t('loan.breakeven.fixed_costs', count: 1)
    data.addColumn 'number', I18n.t('loan.breakeven.amount')

    for key,cost of @breakevenFixedCosts
      name = cost.name
      total = cost.amount
      data.addRow [name, total]

    @drawPieChartIntoElement('.breakeven-fixed-cost-chart', data)

  breakevenCostsChart: ->
    data = new google.visualization.DataTable()
    data.addColumn 'string', I18n.t('loan.breakeven.item')
    data.addColumn 'number', I18n.t('loan.breakeven.cost')
    data.addRow ["Cost of Good Sold", @breakevenData["total_cogs"]]
    data.addRow ["Fixed Costs", @breakevenData["total_fixed_costs"]]

    @drawPieChartIntoElement('.breakeven-costs-chart', data)

  breakevenProductProfit: ->
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

    data = new google.visualization.DataTable()
    data.addColumn 'string', I18n.t('loan.breakeven.product')
    data.addColumn 'number', I18n.t('loan.breakeven.profit')

    for key,product of profitData
      name = key
      total = product.profit
      data.addRow [name, total]

    data

  drawPieChartIntoElement: (elementSelector, chartTable) ->
    chart = new google.visualization.PieChart(@$(elementSelector)[0])
    @formatNumbers(chartTable)
    chart.draw(chartTable, @defaultChartOptions)

  defaultChartTable: (productLabel, revenueLabel, chartData) ->
    data = new google.visualization.DataTable()
    data.addColumn 'string', productLabel
    data.addColumn 'number', revenueLabel

    for key,product of chartData
      name = product.name
      total = product.total
      data.addRow [name, total]

    data

  # Style the number as currency with punctuation
  formatNumbers: (data) ->
    currency = '$'
    separator = ','
    formatter = new google.visualization.NumberFormat({
      prefix: currency,
      groupingSymbol: separator,
      fractionDigits: 0
    })

    # Format second column of data. Expects that data is set up as [name, amount].
    formatter.format(data, 1)

  # Note: Not included in Breakeven Financial Model in favor of a simple total costs chart
  # Loads each fixed and production cost as separate slices in a total costs chart
  # All production costs are a shade of a base color
  # All fixed costs are a shade of a different base color
  # breakevenTotalCostsChart: ->
  #   columns = [
  #     {"label":I18n.t('loan.breakeven.item'),"type":"string"},
  #     {"label":I18n.t('loan.breakeven.cost'),"type":"number"}
  #   ]
  #   rows = []
  #
  #   for key,product of @breakevenProductionCosts
  #     name = product.name
  #     total = product.total
  #     rows.push({"c":[{"v": name},{"v": total, "f":null}]})
  #
  #   for key,cost of @breakevenFixedCosts
  #     name = cost.name
  #     total = cost.amount
  #     rows.push({"c":[{"v": name},{"v": total, "f":null}]})
  #
  #   options = @defaultChartOptions
  #   slices = {}
  #
  #   # Color is adjusted per item based on total items in a specific group
  #   # Fixed costs have a different base color than product costs
  #   productionCostLength = @breakevenProductionCosts.length
  #   fixedCostLength = rows.length - productionCostLength
  #   productionIncrement = parseInt((255-102)/productionCostLength)
  #   fixedCostIncrement = parseInt((255-57)/fixedCostLength)
  #
  #   i = 0
  #   for key,row of rows
  #     if key < productionCostLength
  #       slices[parseInt(key)] = {color:
  #         "rgb(#{51 + (productionIncrement * parseInt(key))},
  #         #{102 + (productionIncrement * parseInt(key))},
  #         204)"
  #       }
  #     else
  #       slices[parseInt(key)] = {color:
  #         "rgb(220,
  #         #{57 + (fixedCostIncrement * i)},
  #         #{18 + (fixedCostIncrement * i)})"
  #       }
  #       ++i
  #
  #   options.slices = slices
  #   chartData = {"cols": columns, "rows": rows}
  #   chartData = new google.visualization.DataTable(chartData)
  #   chart = new google.visualization.PieChart(document.getElementById('breakeven-total-costs-chart'))
  #   chart.draw(chartData, options);
