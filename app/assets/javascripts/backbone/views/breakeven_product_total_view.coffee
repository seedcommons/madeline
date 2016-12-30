class MS.Views.BreakevenProductTotalView extends Backbone.View

  # The view is called from the editiable table view.

  # events:
  #   'click tr [data-action="delete"]': 'removeRow'
  #   'click .actions [data-action="add"]': 'addRow'

  initialize: (options) ->
    @products = options.products

    # console.log({@products})
    # console.log(@$el)
    #
    # totalNet = @totalNet()
    # console.log({totalNet})

  totalNet: ->
    sum = _.reduce(@products, (acc, product) =>
      acc + product.net()
    , 0)

    @$('.net').val(sum)
    sum
