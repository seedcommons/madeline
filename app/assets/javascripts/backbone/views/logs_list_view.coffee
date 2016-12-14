class MS.Views.LogsListView extends Backbone.View

  events:
    'click .log [data-action="edit"]': 'editLog'

  editLog: (e) ->
    e.preventDefault()
    console.log("Edit log clicked")
