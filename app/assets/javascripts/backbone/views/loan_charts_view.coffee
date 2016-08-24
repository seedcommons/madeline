class MS.Views.LoanChartsView extends Backbone.View

  el: '.summary-chart'

  initialize: (params) ->
    console.log(params)
    revenueAndCosts = params.revenue_and_costs
    console.log(revenueAndCosts)
