$ ->
  # Toggles for Show Logs/Hide Logs and More/Less
  $(".logs, .log-details").on "show.bs.collapse", ->
    toggle = $("#show-" + @id)
    toggle.data('orig-text', toggle.html()) if !toggle.data('orig-text')
    toggle.html toggle.data('alt-text')
  $(".logs, .log-details").on "hide.bs.collapse", ->
    toggle = $("#show-" + @id + ".collapsed")
    toggle.html toggle.data('orig-text')
