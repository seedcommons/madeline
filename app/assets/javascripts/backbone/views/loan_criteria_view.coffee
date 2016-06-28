class MS.Views.LoanCriteriaView extends Backbone.View

  el: 'section.criteria'

  initialize: (options) ->
    @loanId = options.loanId
    @refreshContent()

  events:
    'ajax:error': 'submitError'

  refreshContent: ->
    MS.loadingIndicator.show()
    @$('.criteria-content').empty()
    $.get "/admin/loans/#{@loanId}/criteria", (html) =>
      MS.loadingIndicator.hide()
      @$('.criteria-content').html(html)

  submitError: (e) ->
    e.stopPropagation()
    MS.errorModal.modal('show')
    MS.loadingIndicator.hide()
