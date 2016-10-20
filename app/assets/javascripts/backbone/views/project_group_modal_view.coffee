class MS.Views.ProjectGroupModalView extends Backbone.View

  el: '#project-group-modal'

  initialize: (params) ->
    @loanId = params.loanId
    @success = params.success

  events:
    'click .cancel': 'close'
    'click .btn-primary': 'submitForm'
    'ajax:complete form': 'submitComplete'

  show: (dialogUrl)->
    MS.loadingIndicator.show()

    $.get dialogUrl, (html) =>
      MS.loadingIndicator.hide()
      @replaceContent(html)
      @$el.modal('show')

  new: (parentId)->
    dialogUrl = "/admin/project_groups/new?loan_id=#{@loanId}"
    dialogUrl += "&parent_id=#{parentId}" if parentId

    @show(dialogUrl)

  edit: (id) ->
    @show("/admin/project_groups/#{id}/edit")

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
