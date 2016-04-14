class MS.Views.CalendarView extends Backbone.View

  el: 'body'

  initialize: (params) ->
    # Initialize calendar
    $('#calendar').fullCalendar({
      eventRender: (event, element) ->
        element.find('.fc-title').html(event.title)
    })

    @.renderCalEvents(params.events)

  renderCalEvents: (events) ->
    self = @;

    $(events).each (key, calEvent) ->
      self.renderCalEvent(calEvent)

  renderCalEvent: (calItem) ->
    $('#calendar').fullCalendar( 'renderEvent', calItem, stick: true )
