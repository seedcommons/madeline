class MS.Views.BreakevenProductView extends Backbone.View

  # The view is called from the editiable table view.

  events:
    'change input': 'changed'

  initialize: (options) ->
    @total_fixed_costs = 0
    @Q = 0.0

    # Refactor to separate all calculations from Dom
    @cost = @readFromDom('cost')
    @percentage_of_sales = @getPercentageOfSales()
    @price = @readFromDom('price')
    @profit = @getProfit()
    @quantity = @getQuantity()
    @ps = @getPs()
    @net = @getNet()

    @updateDom()

  updateDom: ->
    @writeToDom('net', @net)
    @writeToDom('quantity', @quantity)
    @writeToDom('ps', @ps)

    console.log({@total_fixed_costs, @quantity, @price, @cost, @profit, @percentage_of_sales, @net, @ps})
    # console.log(@$el)

  isValid: ->
    !isNaN(@getNet()) && !isNaN(@getPs())

  name: ->
    @$('.name').val()

  getProfit: ->
    @price - @cost

  getNet: ->
    @profit * @quantity

  getPs: ->
    @profit * @percentage_of_sales

  getQuantity: ->
    @percentage_of_sales * @Q

  getPercentageOfSales: ->
    @readFromDom('percentage_of_sales') / 100

  readFromDom: (fieldName) ->
    value = @$(".#{fieldName}").val()
    parseFloat(value)

  writeToDom: (fieldName, value) ->
    @$(".#{fieldName}").val(value.toFixed())

  totalsUpdated: (totals) ->
    @total_fixed_costs = totals.totalFixedCosts
    @Q = totals.Q

    @updateDom()

  changed: () ->
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
