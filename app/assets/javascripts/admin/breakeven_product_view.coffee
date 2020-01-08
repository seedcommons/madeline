class MS.Views.BreakevenProductView extends Backbone.View

  # The view is called from the editiable table view.

  events:
    'change input[data-breakeven-item="price"]': 'changed'
    'change input[data-breakeven-item="cost"]': 'changed'
    'change input[data-breakeven-item="percentage-of-sales"]': 'changed'
    'click td [data-action="delete"]': 'removeRow'

  initialize: (options) ->
    @Q = 0.0

    # Refactor to separate all calculations from Dom
    @_cost = @readFromDom('cost')
    @_price = @readFromDom('price')
    @_percentageOfSales = @readPercentageOfSalesFromDom()

    @updateDom()

  changed: ->
    @_price = @readFromDom('price')
    @_cost = @readFromDom('cost')
    @_percentageOfSales = @readPercentageOfSalesFromDom()
    @updateDom()
    @trigger('product.changed', @)

  cost: ->
    @_cost

  getValueForDom: (value) ->
    if @isValid()
      value.toFixed()
    else
        ''

  isValid: ->
    !isNaN(@revenue()) && !isNaN(@ps())

  percentageOfSales: ->
    @_percentageOfSales

  price: ->
    @_price

  profit: ->
    @price() - @cost()

  ps: ->
    @profit() * @percentageOfSales()

  quantity: ->
    Math.round(@percentageOfSales() * @Q)

  readFromDom: (fieldName) ->
    value = @$("[data-breakeven-item='#{fieldName}']").val()
    parseFloat(value)

  readPercentageOfSalesFromDom: ->
    @readFromDom('percentage-of-sales') / 100

  removeRow: ->
    @trigger 'breakevenProductView.removed', @

  revenue: ->
    @profit() * @quantity()

  totalCost: ->
    @cost() * @quantity()

  totalsUpdated: (totals) ->
    @Q = totals.Q

    @updateDom()

  updateDom: ->
    @writeToDom('revenue', @revenue())
    @writeToDom('quantity', @quantity())
    @writeToDom('quantity_display_value', @quantity())
    @writeToDom('total_cost', @totalCost())

  writeToDom: (fieldName, value) ->
    valueForDom = @getValueForDom(value)
    @$("[data-breakeven-item='#{fieldName}']").val(valueForDom).text(valueForDom)
