class MS.Views.TransactionsView extends Backbone.View
  el: '.transactions'

  initialize: ->
    console.log('TransactionsView created')

  events:
   'click [data-action="new-transaction"]': 'newTransaction'

  newTransaction: ->
    console.log('Modal will open here')
