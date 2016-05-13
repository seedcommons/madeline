class MS.Views.LogModalView extends Backbone.View

  el: '#log-modal'

  # events:

  initialize: (params) ->
    $('#log-modal').modal('show')
