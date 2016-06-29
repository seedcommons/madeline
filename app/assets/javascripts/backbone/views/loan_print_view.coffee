class MS.Views.LoanPrintView extends Backbone.View

  initialize: (params) ->
    @loanId = params.loanId
    MS.loanCriteriaView = new MS.Views.LoanCriteriaView({loanId: @loanId})
