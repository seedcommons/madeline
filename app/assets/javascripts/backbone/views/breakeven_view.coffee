class MS.Views.BreakevenView extends Backbone.View

  # The view is called from the loan questionnare view.

  events:
    'change .editable-table[data-table="fixed_costs"] input.amount': 'totalFixedCostsChanged'

  initialize: (e) ->
    console.log({totalFixedCosts: @totalFixedCosts()})

    @products = @$("tr[data-group='product']:not('.hidden')").map (index, productRow) =>
      new MS.Views.BreakevenProductView(el: productRow)

    totals = @$("tr[data-group='product-total']").map (index, totalRow) =>
      new MS.Views.BreakevenProductTotalView(el: totalRow, products: @products)

    # Should be 1 and only 1 total row
    @total = totals[0]

  totalFixedCosts: =>
    _.reduce(@$('.editable-table[data-table="fixed_costs"] input.amount'), (acc, amount) =>
      value = parseFloat($(amount).val())
      acc += value unless isNaN(value)

      return acc
    , 0)

  totalFixedCostsChanged: =>
    totalFixedCosts = @totalFixedCosts()
    Q = @totalFixedCosts() / @total.totalPs()

    costs = {totalFixedCosts: @totalFixedCosts(), Q: Q}
    console.log(costs)
    _.each @products, (product) =>
      product.totalsUpdated(costs)

    @total.updated(costs)


