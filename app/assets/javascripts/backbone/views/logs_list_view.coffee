class MS.Views.LogsListView extends Backbone.View

  events:
    'click .log [data-action="edit"]': 'editLog'

  editLog: (e) ->
    e.preventDefault()
    @$('#project-log-modal .modal').modal('show')
