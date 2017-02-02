class MS.Views.ProjectGroupModalView extends Backbone.View

  el: '#project-group-modal'

  initialize: (params) ->
    new MS.Views.AutoLoadingIndicatorView()
    @projectId = params.projectId
    @success = params.success

  events:
    'click .cancel': 'close'
    'click .btn-primary': 'submitForm'
    'ajax:complete form': 'submitComplete'

  show: (dialogUrl) ->
    $.get dialogUrl, (html) =>
      @replaceContent(html)
      @$el.modal('show')

  new: (parentId) ->
    parentId = parentId || ''
    @show("/admin/project_groups/new?project_id=#{@projectId}&parent_id=#{parentId}")

  edit: (id) ->
    @show("/admin/project_groups/#{id}/edit")

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
