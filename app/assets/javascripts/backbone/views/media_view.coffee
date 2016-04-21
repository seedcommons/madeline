class MS.Views.MediaView extends Backbone.View
  events:
    'click a.edit': 'showMediaModal'

  showMediaModal: (e) ->
    e.preventDefault()
    @$('.edit-media').modal('show')
