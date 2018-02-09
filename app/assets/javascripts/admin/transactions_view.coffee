class MS.Views.TransactionsView extends Backbone.View
  el: '.transactions'

  events:
   'click [data-action="new-transaction"]': 'showTransactionModal'
   'click [data-action="show-transaction"]': 'showTransactionModal'

  new: (loanId) ->
    @loanId = loanId

  showTransactionModal: (e) ->
    e.preventDefault()
    link = e.currentTarget
    action = @$(link).data('action')

    unless @transactionModalView
      @transactionModalView = new MS.Views.TransactionModalView(@loanId)

    if action == 'show-transaction'
      @transactionModalView.show(@$(link).data('id'), @$(link).data('project-id'))
    else
      @transactionModalView.new(@$(link).data('project-id'))
