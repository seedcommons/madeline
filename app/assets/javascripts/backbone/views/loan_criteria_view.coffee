class MS.Views.LoanCriteriaView extends Backbone.View

  # 4301 todo: figure out best way to share between loan criteria and post analysis
  el: 'section.criteria'

  initialize: (options) ->
    @loanId = options.loanId
    @refreshContent()

  events:
    'ajax:error': 'submitError'

  refreshContent: ->
    MS.loadingIndicator.show()
    @$('.loan-criteria').empty()
    $.get "/admin/loans/#{@loanId}/criteria", (html) =>
      MS.loadingIndicator.hide()
      @$('.loan-criteria').html(html)

  submitError: (e) ->
    e.stopPropagation()
    MS.errorModal.modal('show')
    MS.loadingIndicator.hide()
