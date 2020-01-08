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

  updateDom: ->
    @writeToDom('revenue', @revenue())
    @writeToDom('quantity', @quantity())
    @writeToDom('quantity_display_value', @quantity())
    @writeToDom('total_cost', @totalCost())

  isValid: ->
    !isNaN(@revenue()) && !isNaN(@ps())

  price: ->
    @_price

  cost: ->
    @_cost

  profit: ->
    @price() - @cost()

  revenue: ->
    @profit() * @quantity()

  totalCost: ->
    @cost() * @quantity()

  ps: ->
    @profit() * @percentageOfSales()

  quantity: ->
    Math.round(@percentageOfSales() * @Q)

  percentageOfSales: ->
    @_percentageOfSales

  readPercentageOfSalesFromDom: ->
    @readFromDom('percentage-of-sales') / 100

  readFromDom: (fieldName) ->
    value = @$("[data-breakeven-item='#{fieldName}']").val()
    parseFloat(value)

  writeToDom: (fieldName, value) ->
    valueForDom = @getValueForDom(value)
    @$("[data-breakeven-item='#{fieldName}']").val(valueForDom).text(valueForDom)

  getValueForDom: (value) ->
    if @isValid()
      value.toFixed()
    else
      ''

  totalsUpdated: (totals) ->
    @Q = totals.Q

    @updateDom()

  changed: () ->
    @_price = @readFromDom('price')
    @_cost = @readFromDom('cost')
    @_percentageOfSales = @readPercentageOfSalesFromDom()
    @updateDom()
    @trigger('product.changed', @)

  removeRow: () ->
    @trigger 'breakevenProductView.removed', @
