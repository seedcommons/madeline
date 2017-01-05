class MS.Views.BreakevenProductView extends Backbone.View

  # The view is called from the editiable table view.

  events:
    'change input.price': 'changed'
    'change input.cost': 'changed'
    'change input.percentage_of_sales': 'changed'

  initialize: (options) =>
    @total_fixed_costs = @readFromDom('total_fixed_costs')
    @Q = 0.0

    # Refactor to separate all calculations from Dom
    @_cost = @readFromDom('cost')
    @_price = @readFromDom('price')
    @_percentageOfSales = @readPercentageOfSalesFromDom()

    @updateDom()

  updateDom: ->
    @writeToDom('net', @net())
    @writeToDom('quantity', @quantity())
    @writeToDom('quantity_display_value', @quantity())
    @writeToDom('ps', @ps())

  isValid: =>
    !isNaN(@net()) && !isNaN(@ps())

  name: =>
    @$('.name').val()

  price: ->
    @_price

  cost: ->
    @_cost

  profit: =>
    @price() - @cost()

  net: =>
    @profit() * @quantity()

  ps: =>
    @profit() * @percentageOfSales()

  quantity: =>
    Math.round(@percentageOfSales() * @Q)

  percentageOfSales: =>
    @_percentageOfSales

  readPercentageOfSalesFromDom: =>
    @readFromDom('percentage_of_sales') / 100

  readFromDom: (fieldName) ->
    value = @$(".#{fieldName}").val()
    parseFloat(value)

  writeToDom: (fieldName, value) ->
    valueForDom = @getValueForDom(value)
    @$(".#{fieldName}").val(valueForDom).text(valueForDom)

  getValueForDom: (value) =>
    return value.toFixed() if @isValid()
    ""

  totalsUpdated: (totals) ->
    @total_fixed_costs = totals.totalFixedCosts
    @Q = totals.Q

    @updateDom()

  changed: () ->
    @_price = @readFromDom('price')
    @_cost = @readFromDom('cost')
    @_percentageOfSales = @readPercentageOfSalesFromDom()
    @updateDom()
    @trigger("product:changed", @)
