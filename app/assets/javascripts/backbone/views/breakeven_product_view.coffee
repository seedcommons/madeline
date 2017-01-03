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
    @cost = @readFromDom('cost')
    @price = @readFromDom('price')
    @_percentageOfSales = @readPercentageOfSalesFromDom()

    @updateDom()

  updateDom: ->
    @writeToDom('net', @net())
    @writeToDom('quantity', @quantity())
    @writeToDom('ps', @ps())

    console.log({@total_fixed_costs, quantity: @quantity(), @price, @cost, profit: @profit(), percentageOfSales: @percentageOfSales(), net: @net(), ps: @ps()})
    # console.log(@$el)

  isValid: =>
    !isNaN(@net()) && !isNaN(@ps())

  name: =>
    @$('.name').val()

  profit: =>
    @price - @cost

  net: =>
    @profit() * @quantity()

  ps: =>
    @profit() * @percentageOfSales()

  quantity: =>
    Math.round(@percentageOfSales() * @Q)

  percentageOfSales: =>
    @_percentageOfSales

  readPercentageOfSalesFromDom: ->
    @readFromDom('percentage_of_sales') / 100

  readFromDom: (fieldName) ->
    value = @$(".#{fieldName}").val()
    parseFloat(value)

  writeToDom: (fieldName, value) ->
    if @isValid
      @$(".#{fieldName}").val(value.toFixed())
    else
      @$(".#{fieldName}").val("N/A")


  totalsUpdated: (totals) ->
    @total_fixed_costs = totals.totalFixedCosts
    @Q = totals.Q

    @updateDom()

  changed: () ->
    @price = @readFromDom('price')
    @cost = @readFromDom('cost')
    @_percentageOfSales = @readPercentageOfSalesFromDom()
    @updateDom()
    @trigger("product:changed", @)

  # addRow: (e) ->
  #   e.preventDefault()
  #   $button = @$(e.currentTarget)
  #   $table = $button.closest('table')
  #   $new_row = $table.find('tr.hidden').clone()
  #   $new_row.removeClass('hidden')
  #   $table.append($new_row)
  #
  # removeRow: (e) ->
  #   e.preventDefault()
  #   $row = @$(e.currentTarget).closest('tr')
  #   $row.remove()
