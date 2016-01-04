$ ->
  $('#calendar').fullCalendar()

  $('.currency_symbol').tooltip
    placement: 'left'
    delay: 500
    container: 'body'

  # Tooltip for untranslated text
  $('.foreign_language').popover(
    html: true
    placement: "bottom"
    container: "body"
  ).click (e) ->
    # Prevent rowlink from firing when clicking to show tooltip
    e.stopPropagation()
