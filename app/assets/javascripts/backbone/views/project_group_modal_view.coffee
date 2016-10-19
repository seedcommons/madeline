class MS.Views.ProjectGroupModalView extends Backbone.View

  el: '#project-group-modal'

  initialize: (params) ->
    new MS.Views.AutoLoadingIndicatorView()
    @loanId = params.loanId
    @success = params.success

  events:
    'click .cancel': 'close'
    'click .btn-primary': 'submitForm'
    'ajax:complete form': 'submitComplete'

  show: ->
    $.get "/admin/project_groups/new?loan_id=#{@loanId}", (html) =>
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
    new MS.Views.TranslationsView(el: @$('[data-content-translatable="project_group"]'))
