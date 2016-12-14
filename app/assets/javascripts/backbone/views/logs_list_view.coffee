class MS.Views.LogsListView extends Backbone.View

  events:
    'click .log [data-action="edit"]': 'editLog'

  editLog: (e) ->
    e.preventDefault()
    logId = @$(e.currentTarget).closest('.log').data('id')
    console.log(logId)
    # @$('#project-log-modal .modal').modal('show')
