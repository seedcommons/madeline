# This creates and controls a special calendar view for the dashboard.
class MS.Views.DashboardCalendarView extends MS.Views.CalendarView

  el: '.upcoming-events'

  initialize: (params) ->
    @prepareVariables(params)
    @prepareDefaultSettings(params, this)

    # Get the numbered day of the week for 2 days before today
    cal_start = moment(new Date()).subtract(2, 'days').day()

    @settings =
      customButtons:
        legend:
          text: I18n.t('calendar.legend', locale: params.locale)
      header:
        # Show no buttons
        left: ''
        center: ''
        right: ''
      defaultView: 'basicWeek'
      firstDay: cal_start

    @initializeCalendar()
