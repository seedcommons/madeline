class MS.Views.CalendarView extends Backbone.View

  el: '.calendar'

  initialize: (params) ->
    # Initialize calendar

    @$calendar = @$('#calendar')

    @$calendar.fullCalendar({
      # Changes the default event render to load in html rather than title only
      eventRender: (calEvent, element) ->
        element.find('.fc-title').html(calEvent.title)
    })

    $('[data-toggle="popover"]').popover()

    popoverContent = @$("#legend-content").html()
    @$('#show-legend').attr("data-content", popoverContent)

    @renderCalEvents(params.calEvents)

  renderCalEvents: (calEvents) ->
    $(calEvents).each (key, calEvent) =>
      this.renderCalEvent(calEvent)

  renderCalEvent: (calItem) ->
    @$calendar.fullCalendar('renderEvent', calItem, stick: true)

  rerenderEvents: (e) ->
    @$calendar.fullCalendar('rerenderEvents')
