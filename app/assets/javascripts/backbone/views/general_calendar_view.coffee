# This creates and controls a standard calendar which displays a standard month and week view.
class MS.Views.GeneralCalendarView extends MS.Views.CalendarView

  el: '.calendar'

  initialize: (params) ->
    @prepareVariables(params)

    # Initialize calendar
    @$calendar.fullCalendar
      # Changes the default event render to load in html rather than title only
      eventRender: @eventRender.bind(this)
      eventDrop: @eventDrop.bind(this)
      loading: @loading.bind(this)
      events: params.calendarEventsUrl
      lang: params.locale
      height: 'auto'
      allDayDefault: true
      customButtons:
        legend:
          text: I18n.t('calendar.legend', locale: params.locale)
      header:
        left: 'prev,next today'
        center: 'title'
        right: 'month,basicWeek legend'
      dayClick: @dayClick.bind(this)

    @renderLegend()
