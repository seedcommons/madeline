class MS.Views.LoanChartsView extends Backbone.View

  el: '.summary-chart'

  initialize: (params) ->
    @revenueAndCosts = params.revenue_and_costs
    @loadCharts()

  revenueChart: () ->
    # @revenueData = @revenueAndCosts['revenue']
    # console.log(@revenueData)

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
    chart.draw(data, {width: 400, height: 240});

  loadCharts: () ->
      google.charts.load('current', {'packages':['corechart']});
      google.charts.setOnLoadCallback(@revenueChart);
