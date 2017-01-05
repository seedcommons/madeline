class MS.Views.BreakevenProductTotalView extends Backbone.View

  # The view is called from the editiable table view.

  # events:
  #   'click tr [data-action="delete"]': 'removeRow'
  #   'click .actions [data-action="add"]': 'addRow'

  initialize: (options) ->
    @products = options.products

    @totalFixedCosts = parseFloat(@$('.total_fixed_costs').val())

    _.each @products, (product) =>
      product.on "product:changed", () =>
        @calculateTotals()

    # Defer loading of totals until the dom is ready
    $ =>
      @calculateTotals()

  calculateTotals: ->
    @notifyProducts()

    totalPrice = @totalPrice()
    totalCost = @totalCost()
    totalQuantity = @totalQuantity()
    totalPs = @totalPs()
    totalPercentageOfSales = @totalPercentageOfSales()
    Q = @Q()

    totals = {totalPrice, totalCost, totalQuantity, totalPs, totalPercentageOfSales, @totalFixedCosts, Q}
    @writeTotalsToDom(totals)

  totalPrice: ->
    _.reduce(@products, (acc, product) =>
      acc += product.price() if product.isValid()

      return acc
    , 0)

  totalCost: ->
    _.reduce(@products, (acc, product) =>
      acc += product.cost() if product.isValid()

      return acc
    , 0)

  totalQuantity: ->
    _.reduce(@products, (acc, product) =>
      acc += product.quantity() if product.isValid()

      return acc
    , 0)

  totalPs: ->
    _.reduce(@products, (acc, product) =>
      acc += product.ps() if product.isValid()

      return acc
    , 0.0)


  totalPercentageOfSales: ->
    _.reduce(@products, (acc, product) =>
      acc += product.percentageOfSales() if product.isValid()

      return acc
    , 0)

  Q: ->
    @totalFixedCosts / @totalPs()

  notifyProducts: () ->
    _.each @products, (product) =>
      product.totalsUpdated({@totalFixedCosts, Q: @Q()})

  updated: (totals) ->
    @totalFixedCosts = totals.totalFixedCosts

    @calculateTotals()

  writeTotalsToDom: (totals) ->
    @$('.percentage_of_sales').val("#{totals.totalPercentageOfSales * 100} %")
    @$('.price').val(totals.totalPrice.toFixed())
    @$('.cost').val(totals.totalCost.toFixed())
    @$('.quantity').val(totals.totalQuantity.toFixed())
