class MS.Views.CalendarView extends Backbone.View

  el: '#calendar'

  initialize: (params) ->
    # Initialize calendar
    @$el.fullCalendar({
      eventRender: (event, element) ->
        element.find('.fc-title').html(event.title)
    })

    @renderCalEvents(params.events)

  renderCalEvents: (events) ->
    $(events).each (key, calEvent) =>
      this.renderCalEvent(calEvent)

  renderCalEvent: (calItem) ->
    @$el.fullCalendar('renderEvent', calItem, stick: true)
