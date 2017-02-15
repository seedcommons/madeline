class MS.Views.DashboardCalendarView extends Backbone.View

  el: '.upcoming-events'

  initialize: (params) ->
    # Initialize calendar
    @$calendar = @$('#calendar')

    @$calendar.fullCalendar
      # Changes the default event render to load in html rather than title only
      eventRender: @eventRender.bind(this)
      loading: @loading.bind(this)
      events: params.calendarEventsUrl
      height: 'auto'
      lang: params.locale
      customButtons:
        legend:
          text: I18n.t('calendar.legend', locale: params.locale)
      header:
        left: ''
        center: ''
        right: ''
      allDayDefault: true

    @renderLegend()

  eventRender: (calEvent) -> calEvent.html

  loading: (isLoading) ->
    MS.loadingIndicator[if isLoading then 'show' else 'hide']()

  renderLegend: (e) ->
    # We use the .ms-popover class with trigger: manual. This is handled in ApplicationView.
    @$('.fc-legend-button').addClass('ms-popover').popover
      content: @$('#legend-content').html()
      html: true
      placement: 'left'
      toggle: 'popover'
      title: 'Legend'
      trigger: 'manual'

  refresh: (e) ->
    @$calendar.fullCalendar('refetchEvents')
