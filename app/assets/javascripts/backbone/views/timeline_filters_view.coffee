# Controls the type and status filter selects.
class MS.Views.TimelineFiltersView extends Backbone.View
  FILTERS: ['type']

  initialize: ->
    uri = URI(window.location.href)
    @FILTERS.forEach (filter) =>
      @$("select[name=#{filter}]").val(uri.query(true)[filter])

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