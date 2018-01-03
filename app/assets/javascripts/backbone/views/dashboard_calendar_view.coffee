# This creates and controls a special calendar view for the dashboard.
class MS.Views.DashboardCalendarView extends MS.Views.CalendarView

  el: '.upcoming-events'

  initialize: (params) ->
    settings =
      header:
        # Show no buttons
        left: ''
        center: ''
        right: ''
      # Get the numbered day of the week for 2 days before today
      firstDay: moment(new Date()).subtract(2, 'days').day()

    @initializeCalendar(params, this, settings)
    @switchView('basicWeek')
