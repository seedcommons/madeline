class MS.Views.LogsListView extends Backbone.View

  events:
    'click .log [data-action="edit"]': 'editLog'
    'click .log [data-action="delete"]': 'deleteLog'

  editLog: (e) ->
    e.preventDefault()
    console.log("Edit log clicked")

  deleteLog: (e) ->
    e.preventDefault()
    console.log("Delete log clicked")
