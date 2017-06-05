class MS.Views.TransactionModalView extends Backbone.View
  el: '#transaction-modal'

  initialize: (params) ->
    console.log('TransactionModalView created')
    @loanId = params.loanId
    console.log(@loanId)
