class MS.Views.PrintView extends Backbone.View

  events:
    'click [data-action="print"]': 'print'

  print: ->
    window.print()
