$ ->
  # show active tab on reload
  if location.hash != ''
    $('a[href="' + location.hash + '"]').tab 'show'
  # remember the hash in the URL without jumping
  $('a[data-toggle="tab"]').on 'shown.bs.tab', (e) ->
    if history.pushState
      history.pushState null, null, '#' + $(e.target).attr('href').substr(1)
    else
      location.hash = '#' + $(e.target).attr('href').substr(1)

# Trigger popstate as a Backbone event
window.onpopstate = (event) ->
  Backbone.trigger('popstate', event)
