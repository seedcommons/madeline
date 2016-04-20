class MS.Views.TimelineFilterView extends Backbone.View

  el: 'body'

  events: (params) ->
    'click .filter .btn': 'filterSteps'

  filterSteps: (e) ->
    item = e.currentTarget
    selected = $(item).find('input')[0].value
    if selected == "incomplete"
      $('.step.completed').hide()
    else if selected == "all"
      $('.step').show()
