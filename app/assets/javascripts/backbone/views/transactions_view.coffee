class MS.Views.TransactionsView extends Backbone.View
  el: '.transactions'

  events:
   'click [data-action="new-transaction"]': 'newTransaction'

  newTransaction: ->
    @$('#transaction-modal').modal('show')
