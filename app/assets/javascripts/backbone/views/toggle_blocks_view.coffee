# Allows for show/hide of blocks with id referenced by 'data' attribute of link
class MS.Views.ToggleBlocksView extends Backbone.View

  events:
    'click a.action.toggle-action': 'toggleBlock'

  toggleBlock: (e) ->
    e.preventDefault()
    id = $(e.currentTarget).attr('data')
    $("#" + id).toggle()

