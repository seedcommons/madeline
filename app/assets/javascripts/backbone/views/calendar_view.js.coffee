class MS.Views.CalendarView extends Backbone.View

  el: '.calendar'

  initialize: (params) ->
    # Initialize calendar

    @$calendar = @$('#calendar')

    @$calendar.fullCalendar
      # Changes the default event render to load in html rather than title only
      eventRender: (calEvent, element) ->
        element.find('.fc-title').html(calEvent.title)
      customButtons:
        legend:
          text: 'Legend'
      header:
        left: 'prev,next today'
        center: 'title'
        right: 'month,agendaWeek legend'
      allDayDefault: true

    @renderLegend()
    @renderCalEvents(params.calEvents)

  #JE Todo: not needed once source used
  renderCalEvents: (calEvents) ->
    $(calEvents).each (key, calEvent) =>
      this.renderCalEvent(calEvent)

  renderCalEvent: (calItem) ->
    @$calendar.fullCalendar('renderEvent', calItem, stick: true)

  refresh: (e) ->
    # UNCOMMENT ONCE AJAX EVENT FETCHING IS IMPLEMENTED
    # @$calendar.fullCalendar('refetchEvents')

  renderLegend: (e) ->
    $('[data-toggle="popover"]').popover()
    popoverContent = @$('#legend-content').html()

    @$('.fc-legend-button').popover
      content: popoverContent
      html: true
      placement: 'left'
      toggle: 'popover'
      title: 'Legend'
