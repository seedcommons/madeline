# Toggles between show and edit modes for a show/edit view
class MS.Views.ShowEditView extends Backbone.View

  events:
    'click .edit-action': 'showEdit'

  showEdit: ->
    @$el.addClass('edit-view').removeClass('show-view')
