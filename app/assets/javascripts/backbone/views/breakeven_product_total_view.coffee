class MS.Views.BreakevenProductTotalView extends Backbone.View

  # The view is called from the editiable table view.

  # events:
  #   'click tr [data-action="delete"]': 'removeRow'
  #   'click .actions [data-action="add"]': 'addRow'

  initialize: (options) ->
    @products = options.products

    _.each @products, (product) =>
      product.on "product:changed", () =>
        @calculateTotals()

    # Defer loading of totals until the dom is ready
    $ =>
      @calculateTotals()

  calculateTotals: ->
    totalNet = @totalNet()
    totalPs = @totalPs()
    totalPercentageOfSales = @totalPercentageOfSales()
    totalFixedCosts = @totalFixedCosts()
    Q = @Q()

    totals = {totalNet, totalPs, totalPercentageOfSales, totalFixedCosts, Q}
    console.log(totals)

    @notifyProducts(totals)

  totalNet: ->
    sum = _.reduce(@products, (acc, product) =>
      acc += product.net() if product.isValid()

      return acc
    , 0)

    @$('.net').val(sum)
    sum

  totalPs: ->
    sum = _.reduce(@products, (acc, product) =>
      acc += product.ps() if product.isValid()

      return acc
    , 0.0)

    @$('.ps').val(sum)
    sum


  totalPercentageOfSales: ->
    sum = _.reduce(@products, (acc, product) =>
      acc += product.percentageOfSales() if product.isValid()

      return acc
    , 0)

    @$('.percentage_of_sales').val(sum)
    sum


  totalFixedCosts: ->
    val = @$('.total_fixed_costs').val()
    parseFloat(val)

  Q: ->
    q = @totalFixedCosts() / @totalPs()

    @$('.price').val(q)
    q

  notifyProducts: (totals) ->
    _.each @products, (product) =>
      product.totalsUpdated(totals)

  updated: (totals) ->
    console.log totals
    @$('.total_fixed_costs').val(totals.totalFixedCosts)

    @calculateTotals()
