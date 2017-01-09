class MS.Views.BreakevenView extends Backbone.View

  # The view is called from the loan questionnare view.

  events:
    'change .editable-table[data-table="fixed_costs"] input.amount': 'totalFixedCostsChanged'

  initialize: (e) ->
    @$('.editable-breakeven-table').each (index, table) =>
      new MS.Views.EditableBreakevenTableView(el: table)

    @products = @$('tr[data-group="product"]:not(".hidden")').map (index, productRow) =>
      new MS.Views.BreakevenProductView(el: productRow)

    @total = new MS.Views.BreakevenProductTotalView(el: @$("tr[data-group='product-total']").first(), products: @products)

    Backbone.on 'LoanQuestionnairesView:edit', ()=>
      @totalFixedCostsChanged()

  totalFixedCosts: ->
    _.reduce(@$('.editable-table[data-table="fixed_costs"] input.amount'), (acc, amount) =>
      value = parseFloat($(amount).val())
      acc += value unless isNaN(value)
      return acc
    , 0)

  totalFixedCostsChanged: ->
    Q = @totalFixedCosts() / @total.totalPs()

    costs = {totalFixedCosts: @totalFixedCosts(), Q: Q}
    _.each @products, (product) =>
      product.totalsUpdated(costs)

    @total.updated(costs)

