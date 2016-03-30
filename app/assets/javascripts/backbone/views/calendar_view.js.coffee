class MS.Views.CalendarView extends Backbone.View

  el: '#calendar'

  events:
    'click .fc-event-container': 'test_function'

  initialize: (params) ->
    console.log("initialize")

  test_function: (event) ->
    console.log(event.currentTarget)
