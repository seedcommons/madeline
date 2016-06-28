# Allows for show/hide of blocks with id referenced by 'data' attribute of link
# or dynamic exposure of content stored into custom attributes of a link
class MS.Views.ToggleBlocksView extends Backbone.View

  events:
    'click a.action.toggle-action': 'toggleBlock'
    'click a.action.show-content-action': 'showBlockContent'

  toggleBlock: (e) ->
    e.preventDefault()
    id = $(e.currentTarget).attr('data')
    $("#" + id).toggle()

  showBlockContent: (e) ->
    e.preventDefault()
    id = $(e.currentTarget).attr('block-id')
    content = $(e.currentTarget).attr('block-content')
    $("#" + id).html(content)
