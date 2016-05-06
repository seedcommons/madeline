class MS.Views.CalendarView extends Backbone.View

  el: '.calendar'

  initialize: (params) ->
    # Initialize calendar

    @$calendar = @$('#calendar')

    @$calendar.fullCalendar
      # Changes the default event render to load in html rather than title only
      eventRender: @eventRender.bind(this),
      loading: @loading.bind(this),
      events: params.calendar_events_url
      customButtons:
        legend:
          text: 'Legend'
      header:
        left: 'prev,next today'
        center: 'title'
        right: 'month,agendaWeek legend'
      allDayDefault: true

    @renderLegend()

  refresh: (e) ->
    @$calendar.fullCalendar('refetchEvents')

  renderLegend: (e) ->
    $('[data-toggle="popover"]').popover()
    popoverContent = @$('#legend-content').html()

    @$('.fc-legend-button').popover
      content: popoverContent
      html: true
      placement: 'left'
      toggle: 'popover'
      title: 'Legend'

  eventRender: (calEvent, element) ->
    element.find('.fc-title').html(calEvent.title)

  loading: (isLoading) ->
    MS.loadingIndicator[if isLoading then 'show' else 'hide']()
