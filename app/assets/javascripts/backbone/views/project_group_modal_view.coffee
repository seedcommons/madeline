class MS.Views.ProjectGroupModalView extends Backbone.View

  el: '#project-group-modal'

  initialize: (params) ->
    @loanId = params.loanId
    @success = params.success
    @loadContent()

  events:
    'click .cancel': 'hide'
    'click .btn-primary': 'submitForm'
    'ajax:complete form': 'submitComplete'

  hide: ->
    @$el.modal('hide')

  loadContent: ->
    MS.loadingIndicator.show()
    $.get "/admin/project_groups/new?loan_id=#{@loanId}", (html) =>
      MS.loadingIndicator.hide()
      @replaceContent(html)
      @$el.modal('show')

  submitForm: ->
    MS.loadingIndicator.show()
    @$('form').submit()

  submitComplete: (e, data) ->
    MS.loadingIndicator.hide()
    if parseInt(data.status) == 200 # data.status is sometimes a string, sometimes an int!?
      @hide()
      @success() if @success
    else
      @replaceContent(data.responseText)

  replaceContent: (html) ->
    @$el.find('.modal-content').html(html)
    new MS.Views.TranslationsView(el: @$('[data-content-translatable="project_group"]'));
