class MS.Views.TransactionsView extends Backbone.View
  el: '.transactions'

  initialize: ->
    console.log('TransactionsView created')
    # @transactionModal = new MS.TransactionModalView({})

  events:
   'click [data-action="new-transaction"]': 'newTransaction'

  newTransaction: ->
    console.log('Modal will open here')
    @$('#transaction-modal').modal("show")
