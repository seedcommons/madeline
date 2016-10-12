class MS.Views.ProjectStepModalView extends Backbone.View

  el: '#project-step-modal'

  initialize: (params) ->
    @loanId = params.loanId
    @success = params.success

  events:
    'click .cancel': 'close'
    'click .btn-primary': 'submitForm'
    'ajax:complete form': 'submitComplete'

  show: ->
    MS.loadingIndicator.show()
    $.get "/admin/project_steps/new?loan_id=#{@loanId}&context=timeline_table", (html) =>
      MS.loadingIndicator.hide()
      @replaceContent(html)
      @$el.modal('show')

  close: ->
    @$el.modal('hide')

  submitForm: ->
    MS.loadingIndicator.show()
    @$('form').submit()

  submitComplete: (e, data) ->
    MS.loadingIndicator.hide()
    if parseInt(data.status) == 200 # data.status is sometimes a string, sometimes an int!?
      @close()
      @success() if @success
    else
      @replaceContent(data.responseText)

  replaceContent: (html) ->
    @$el.find('.modal-content').html(html)
    new MS.Views.TranslationsView(el: @$('[data-content-translatable="project_group"]'));
