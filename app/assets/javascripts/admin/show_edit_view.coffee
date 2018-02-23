# Toggles between show and edit modes for a show/edit view
class MS.Views.ShowEditView extends Backbone.View

  events:
    'click .edit-action': 'showEdit'
    'click .show-action': 'showShow'

  showEdit: ->
    @$el.addClass('edit-view').removeClass('show-view')

  showShow: ->
    @$el.addClass('show-view').removeClass('edit-view')
