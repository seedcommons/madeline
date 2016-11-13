# Controls the type and status filter selects.
class MS.Views.TimelineFiltersView extends Backbone.View

  events:
    'submit': 'cancelSubmit'
    'change select': 'filterChanged'

  cancelSubmit: (e) ->
    e.preventDefault()

  filterChanged: (e) ->
    select = @$(e.target)
    @setQuery(select.attr('name'), select.val())

  setQuery: (name, value) ->
    uri = URI(window.location.href)
    if value
      uri.setQuery(name, value)
    else
      uri.removeQuery(name)
    history.replaceState(null, "", uri.href())