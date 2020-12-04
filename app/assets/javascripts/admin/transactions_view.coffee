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
    console.log(action)
    unless @transactionModalView
      console.log("instantiating new txn modal view")
      @transactionModalView = new MS.Views.TransactionModalView({loanId: @loanId, locale: @locale})

    if action == 'new-transaction'
      @transactionModalView.refactored_show(null, "new")
      #@transactionModalView = new MS.Views.TransactionModalView({loanId: @loanId, locale: @locale})
      #@transactionModalView.initialize({loanId: @$(link).data('project-id'), locale: @locale})
    else
      @transactionModalView.refactored_show(@$(link).data('id'), "show")
