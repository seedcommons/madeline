class MS.Views.LogModalView extends Backbone.View

  el: '#log-modal'

  # events:

  initialize: (params) ->
    if params.action == "add-log"
      @showNew(params.stepId)
    else
      @showEdit(params.logId)

  showEdit: (logId) ->
    MS.loadingIndicator.show()
    $.get '/admin/project_logs/' + logId, id: logId, (html) =>
      @replaceContent(html)

  showNew: (stepId) ->
    MS.loadingIndicator.show()
    $.get '/admin/project_logs/new', step_id: stepId, (html) =>
      @replaceContent(html)

  replaceContent: (html) ->
    @$el.find('.modal-content').html(html)
    @$el.modal({show: true})
    MS.loadingIndicator.hide()
