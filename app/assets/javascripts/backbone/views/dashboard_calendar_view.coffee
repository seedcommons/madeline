# This creates and controls a special calendar view for the dashboard.
class MS.Views.DashboardCalendarView extends MS.Views.CalendarView

  el: '.upcoming-events'

  initialize: (params) ->
    # Initialize calendar
    @$calendar = @$('#calendar')

    # Get the numbered day of the week for 2 days before today
    cal_start = moment(new Date()).subtract(2, 'days').day()

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
        # Show no buttons
        left: ''
        center: ''
        right: ''
      allDayDefault: true
      defaultView: 'basicWeek'
      firstDay: cal_start
