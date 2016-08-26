class MS.Views.LoanChartsView extends Backbone.View

  el: '.summary-chart'

  initialize: (params) ->
    @breakevenData = params.breakeven_data
    @loadCharts()

  breakevenFixedCostsChart: () ->
    @breakevenFixedCosts = @breakevenData["fixed_costs"]

    chartData = {}
    columns = [
      {"id":"","label":"Fixed Cost","pattern":"","type":"string"},
      {"id":"","label":"Amount","pattern":"","type":"number"}
    ]

    rows = []
    for key,cost of @breakevenFixedCosts
      name = cost.name
      total = cost.amount
      rows.push({"c":[{"v": name, "f":null},{"v": total, "f":null}]})

    chartData = {"cols": columns, "rows": rows}
    chartData = new google.visualization.DataTable(chartData);
    chart = new google.visualization.PieChart(document.getElementById('breakeven-fixed-cost-chart'));
    chart.draw(chartData, {width: 400, height: 240, title: "Fixed Costs"});

  breakevenProductionCostsChart: () ->
    @breakevenProductionCosts = @breakevenData["cogs"]

    chartData = {}
    columns = [
      {"id":"","label":"Product","pattern":"","type":"string"},
      {"id":"","label":"Production Cost","pattern":"","type":"number"}
    ]

    rows = []
    for key,product of @breakevenProductionCosts
      name = product.name
      total = product.total
      rows.push({"c":[{"v": name, "f":null},{"v": total, "f":null}]})

    chartData = {"cols": columns, "rows": rows}
    chartData = new google.visualization.DataTable(chartData);
    chart = new google.visualization.PieChart(document.getElementById('breakeven-production-cost-chart'));
    chart.draw(chartData, {width: 400, height: 240, title: "Production Cost by Product"});

  breakevenRevenueChart: () ->
    @breakevenRevenue = @breakevenData["revenue"]

    chartData = {}
    columns = [
      {"id":"","label":"Product","pattern":"","type":"string"},
      {"id":"","label":"Revenue","pattern":"","type":"number"}
    ]

    rows = []
    for key,product of @breakevenRevenue
      name = product.name
      total = product.total
      rows.push({"c":[{"v": name, "f":null},{"v": total, "f":null}]})

    chartData = {"cols": columns, "rows": rows}
    chartData = new google.visualization.DataTable(chartData);
    chart = new google.visualization.PieChart(document.getElementById('breakeven-revenue-chart'));
    chart.draw(chartData, {width: 400, height: 240, title: "Revenue by Product"});

  loadCharts: () ->
    google.charts.load('current', {'packages':['corechart']});
    # google.charts.setOnLoadCallback @revenueChart.bind @
    google.charts.setOnLoadCallback @breakevenRevenueChart.bind @
    google.charts.setOnLoadCallback @breakevenProductionCostsChart.bind @
    google.charts.setOnLoadCallback @breakevenFixedCostsChart.bind @

  # TODO: Remove static data chart when all other charts loaded
  revenueChart: () ->
    data = {
      "cols": [
        {"id":"","label":"Product","pattern":"","type":"string"},
        {"id":"","label":"Revenue","pattern":"","type":"number"}
      ],
      "rows": [
        {"c":[{"v":"Product 1","f":null},{"v":80000,"f":null}]},
        {"c":[{"v":"Product 2","f":null},{"v":36000,"f":null}]},
        {"c":[{"v":"Product 3","f":null},{"v":15000,"f":null}]}
      ]
    }

    data = new google.visualization.DataTable(data);
    chart = new google.visualization.PieChart(document.getElementById('revenue-chart'));
    chart.draw(data, {width: 400, height: 240, title: "Revenue by Product"});
