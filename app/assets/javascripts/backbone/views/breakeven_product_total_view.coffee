class MS.Views.BreakevenProductTotalView extends Backbone.View

  # The view is called from the breakeven view.

  initialize: (options) ->
    @products = options.products

    @totalFixedCosts = parseFloat(@$('.total_fixed_costs').val())

    _.each @products, (product) =>
      product.on "product:changed", () =>
        @calculateTotals()

    @calculateTotals()

  calculateTotals: ->
    @notifyProducts()

    totalPrice = @totalPrice()
    totalCost = @totalCost()
    totalQuantity = @totalQuantity()
    totalRevenue = @totalRevenue()
    totalPercentageOfSales = @totalPercentageOfSales()
    totalProductCost = @totalProductCost()
    Q = @Q()

    totals = {totalPrice, totalCost, totalQuantity, totalRevenue, totalPercentageOfSales, totalProductCost, @totalFixedCosts, Q}
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

  totalProductCost: ->
    _.reduce(@products, (acc, product) =>
      acc += product.totalCost() if product.isValid()

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

  totalRevenue: ->
    _.reduce(@products, (acc, product) =>
      acc += product.revenue() if product.isValid()

      return acc
    , 0.0)


  totalPercentageOfSales: ->
    _.reduce(@products, (acc, product) =>
      acc += product.percentageOfSales() if product.isValid()

      return acc
    , 0)

  Q: ->
    @totalFixedCosts / @totalPs()

  notifyProducts: ->
    _.each @products, (product) =>
      product.totalsUpdated({@totalFixedCosts, Q: @Q()})

  updated: (totals) ->
    @totalFixedCosts = totals.totalFixedCosts
    @calculateTotals()

  writeTotalsToDom: (totals) ->
    # Silly JS numbers: Sometime you will see a number like 100.00000000001, hence the rounding
    totalPercentageOfSales = Math.round(totals.totalPercentageOfSales * 100)

    @$('.percentage-of-sales').val("#{totalPercentageOfSales}%")
    @$('.price').val(totals.totalPrice.toFixed())
    @$('.cost').val(totals.totalCost.toFixed())
    @$('.quantity').val(totals.totalQuantity.toFixed())
    @$('.revenue').val(totals.totalRevenue.toFixed())
    @$('.total_cost').val(totals.totalProductCost.toFixed())

  addProduct: (product) ->
    # Don't need to add to products since it was passed by ref
    # @products.push(product)

    product.on "product:changed", () =>
      @calculateTotals()

    @calculateTotals()
