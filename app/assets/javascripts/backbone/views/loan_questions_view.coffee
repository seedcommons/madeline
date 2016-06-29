class MS.Views.LoanQuestionsView extends Backbone.View

  el: 'section.questions'

  initialize: (options) ->
    @loanId = options.loanId
    @refreshContent()

  events:
    'ajax:error': 'submitError'

  refreshContent: ->
    MS.loadingIndicator.show()
    @$('.questions-content').empty()
    $.get "/admin/loans/#{@loanId}/questions", (html) =>
      MS.loadingIndicator.hide()
      @$('.questions-content').html(html)

  submitError: (e) ->
    e.stopPropagation()
    MS.errorModal.modal('show')
    MS.loadingIndicator.hide()
