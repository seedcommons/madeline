class MS.Views.PrintView extends Backbone.View

  el: ".print-view"

  events:
    'click [data-action="print"]': 'print'
    'click [data-action="open-links"]': 'openAttachedLinks'

  initialize: ->
    @resizeBusinessModelCanvas()

  print: ->
    window.print()

  openAttachedLinks: (e) ->
    e.preventDefault()
    links = @$(e.currentTarget).data('links')
    window.open link, "_blank" for link in links

  # Shrink text in business model canvas till it fits on the printed page
  resizeBusinessModelCanvas: ->
    textSelector = '.canvas-cell-title, .canvas-answer, .canvas-help-block'
    _break = false
    while $('.business-model-canvas').height() > $('.business-model-canvas-wrapper').width() && !_break
      $(textSelector).each ->
        fontSize = parseFloat($(this).css('font-size'))
        _break = true if fontSize <= 5 # can't use a real break statement inside each()
        $(this).css 'font-size', "#{fontSize - .5}px"
