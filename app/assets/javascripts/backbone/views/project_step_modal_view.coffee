class MS.Views.ProjectStepModalView extends Backbone.View

  el: '#project-step-modal'

  initialize: (params) ->
    new MS.Views.AutoLoadingIndicatorView()
    @loanId = params.loanId
    @success = params.success

  events:
    'click .cancel': 'close'
    'click .btn-primary': 'submitForm'
    'ajax:complete form': 'submitComplete'

  new: ->
    @loadContent("/admin/project_steps/new?loan_id=#{@loanId}&context=timeline_table")

  edit: (id) ->
    @loadContent("/admin/project_steps/#{id}/edit?context=timeline_table")

  loadContent: (url) ->
    $.get url, (html) =>
      @replaceContent(html)
      @$el.modal('show')

  close: ->
    @$el.modal('hide')

  submitForm: ->
    @$('form').submit()

  submitComplete: (e, data) ->
    if parseInt(data.status) == 200 # data.status is sometimes a string, sometimes an int!?
      @close()
      @success() if @success
    else
      @replaceContent(data.responseText)

  replaceContent: (html) ->
    @$el.find('.modal-content').html(html)
    new MS.Views.TranslationsView(el: @$('[data-content-translatable="project_step"]'))
