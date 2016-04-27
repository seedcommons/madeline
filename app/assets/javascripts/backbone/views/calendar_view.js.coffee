class MS.Views.CalendarView extends Backbone.View

  el: '#calendar'

  initialize: (params) ->
    # Initialize calendar
    @$el.fullCalendar({
      # Changes the default event render to load in html rather than title only
      eventRender: (calEvent, element) ->
        element.find('.fc-title').html(calEvent.title)
    })

    @renderCalEvents(params.calEvents)

  renderCalEvents: (calEvents) ->
    $(calEvents).each (key, calEvent) =>
      this.renderCalEvent(calEvent)

  renderCalEvent: (calItem) ->
    @$el.fullCalendar('renderEvent', calItem, stick: true)

  rerenderEvents: (e) ->
    @$el.fullCalendar('rerenderEvents')
