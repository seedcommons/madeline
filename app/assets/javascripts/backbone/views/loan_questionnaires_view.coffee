class MS.Views.LoanQuestionnairesView extends Backbone.View

  el: 'section.questionnaires'

  initialize: (options) ->
    @loanId = options.loanId
    @refreshContent()

  events:
    'ajax:error': 'submitError'

  refreshContent: ->
    MS.loadingIndicator.show()
    @$('.questionnaires-content').empty()
    $.get "/admin/loans/#{@loanId}/questionnaires", (html) =>
      MS.loadingIndicator.hide()
      @$('.questionnaires-content').html(html)

  submitError: (e) ->
    e.stopPropagation()
    MS.errorModal.modal('show')
    MS.loadingIndicator.hide()
