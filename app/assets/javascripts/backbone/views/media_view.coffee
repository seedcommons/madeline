class MS.Views.MediaView extends Backbone.View
  events:
    'click a.edit': 'showMediaModal'
    'click a.new': 'showMediaModal'

  showMediaModal: (e) ->
    e.preventDefault()
    @$('.edit-media').modal('show')
