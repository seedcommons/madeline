class MS.Views.TransactionModalView extends Backbone.View
  el: '#transaction-modal'

  initialize: (params) ->
    @loanId = params.loanId
