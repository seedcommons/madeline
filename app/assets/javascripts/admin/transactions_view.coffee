class MS.Views.TransactionsView extends Backbone.View
  el: '.transactions'

  events:
   'click [data-action="new-transaction"]': 'showTransactionModal'
   'click [data-action="show-transaction"]': 'showTransactionModal'

  initialize: (params) ->
    @loanId = params.loanId
    @locale = params.locale

  showTransactionModal: (e) ->
    e.preventDefault()
    link = e.currentTarget
    action = @$(link).data('action')
    unless @transactionModalView
      @transactionModalView = new MS.Views.TransactionModalView({loanId: @loanId, locale: @locale})

    if action == 'new-transaction'
      @transactionModalView.show(null, "new")
    else
      @transactionModalView.show(@$(link).data('id'), "show")
