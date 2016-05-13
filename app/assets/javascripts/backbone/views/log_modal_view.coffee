class MS.Views.LogModalView extends Backbone.View

  el: '#log-modal'

  # events:

  initialize: (params) ->
    if params.action == "add-log"
      @showNew(stepId: params.stepId)
    else
      @showEdit(logId: params.logId)

  showEdit: (logId) ->
    MS.loadingIndicator.show()
    console.log('show edit')
    # $.get '/admin/project_logs/' + logId, (html) =>
    #   @replaceContent(html)

  showNew: (stepId) ->
    MS.loadingIndicator.show()
    console.log('show new')
    # TODO: Pass step id param to ajax call
    # $.get '/admin/project_logs/new', (html) =>
    #   @replaceContent(html)

  replaceContent: (html) ->
    @$el.find('.modal-content').html(html)
    @$el.modal({show: true})
    MS.loadingIndicator.hide()
