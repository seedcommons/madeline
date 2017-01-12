class MS.Views.BreakevenView extends Backbone.View

  # The view is called from the loan questionnare view.

  events:
    'change .editable-table[data-table="fixed_costs"] input.amount': 'totalFixedCostsChanged'

  initialize: (e) ->
    tables = @$('.editable-table').map (index, table) =>
      new MS.Views.EditableTableView(el: table)

    @products = @$('tr[data-group="product"]:not(".hidden")').map (index, productRow) =>
      new MS.Views.BreakevenProductView(el: productRow)

    @total = new MS.Views.BreakevenProductTotalView(el: @$("tr[data-group='totals']").first(), products: @products)

    Backbone.on 'LoanQuestionnairesView:edit', ()=>
      @totalFixedCostsChanged()

    _.each tables, (table) =>
      table.on 'EditableTableView:rowAdded', ($table, row) =>
        tableName = $table.data('table')
        @addProduct(row) if tableName == "products"

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


  addProduct: (product) ->
    @products.push(product)
    @total.addProduct(product)
    @totalFixedCostsChanged()
