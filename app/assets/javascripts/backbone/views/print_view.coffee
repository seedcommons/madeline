class MS.Views.PrintView extends Backbone.View

  events:
    'click [data-action="print"]': 'print'
    'click [data-action="open-links"]': 'openAttachedLinks'

  print: ->
    window.print()

  openAttachedLinks: (e) ->
    e.preventDefault()
    links = @$(e.currentTarget).data('links')
    window.open link, "_blank" for link in links
