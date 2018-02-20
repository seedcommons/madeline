$ ->
  # Enable link to tab
  hash = document.location.hash
  prefix = "_"
  if hash
    $(".nav-tabs a[href=" + hash.replace(prefix, "") + "]").tab "show"
  else # Select first tab
    $(".nav-tabs a:first").tab "show"

  # Initiate slideshow
  $(".carousel-inner .item").first().addClass "active"
  $(".carousel-indicators li").first().addClass "active"
  $(".carousel").carousel()

  # Toggles for Show Logs/Hide Logs and More/Less
  $(".logs, .log-details").on "show.bs.collapse", ->
    toggle = $("#show-" + @id)
    toggle.data('orig-text', toggle.html()) if !toggle.data('orig-text')
    toggle.html toggle.data('alt-text')
  $(".logs, .log-details").on "hide.bs.collapse", ->
    toggle = $("#show-" + @id + ".collapsed")
    toggle.html toggle.data('orig-text')
