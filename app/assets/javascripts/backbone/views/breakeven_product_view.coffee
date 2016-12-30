class MS.Views.BreakevenProductView extends Backbone.View

  # The view is called from the editiable table view.

  # events:
  #   'click tr [data-action="delete"]': 'removeRow'
  #   'click .actions [data-action="add"]': 'addRow'

  initialize: (options) ->
    cost = @cost()
    percentsales = @percentsales()
    name = @name()
    price = @price()
    quantity = @quantity()
    net = @net()

    console.log({name, quantity, price, cost, percentsales, net})
    # console.log(@$el)

  name: ->
    @$('.name').val()

  quantity: ->
    @$('.quantity').val()

  price: ->
    @$('.price').val()

  cost: ->
    @$('.cost').val()

  percentsales: ->
    @$('.percentsales').val()

  net: ->
    net = (@price() - @cost()) * @quantity()
    @$('.net').val(net)
    net

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
