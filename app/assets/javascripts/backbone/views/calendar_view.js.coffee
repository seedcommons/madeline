class MS.Views.CalendarView extends Backbone.View

  el: '.calendar'

  initialize: (params) ->
    # Initialize calendar
    @$calendar = @$('#calendar')

    @$calendar.fullCalendar
      # Changes the default event render to load in html rather than title only
      eventRender: @eventRender.bind(this)
      loading: @loading.bind(this)
      events: params.calendar_events_url
      customButtons:
        legend:
          text: 'Legend'
      header:
        left: 'prev,next today'
        center: 'title'
        right: 'month,agendaWeek legend'
      allDayDefault: true
      dayClick: @dayClick.bind(this)

    @renderLegend()

  events:
    'click .loan-calendar .cal-step': 'showStepModal'

  dayClick: ->
    if (@$el.find('.loan-calendar'))
      loanId = @$el.find('.loan-calendar').attr('data-loan-id').replace(/loan-/, '')
      new MS.Views.CalendarStepModalView(context: 'calendar', loanId: loanId)

  eventRender: (calEvent, element) ->
    element.find('.fc-title').html(calEvent.title)

  loading: (isLoading) ->
    MS.loadingIndicator[if isLoading then 'show' else 'hide']()

  renderLegend: (e) ->
    $('[data-toggle="popover"]').popover()
    popoverContent = @$('#legend-content').html()

    @$('.fc-legend-button').popover
      content: popoverContent
      html: true
      placement: 'left'
      toggle: 'popover'
      title: 'Legend'

  refresh: (e) ->
    @$calendar.fullCalendar('refetchEvents')

  showStepModal: (e) ->
    calStep = e.currentTarget
    id = @$(calStep).attr('data-step-id').replace(/project_step-/, '')
    new MS.Views.CalendarStepModalView(id: id, context: 'calendar')
    MS.loadingIndicator.show()
