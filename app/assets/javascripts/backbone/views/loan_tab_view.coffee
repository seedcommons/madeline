class MS.Views.LoanTabView extends Backbone.View

  initialize: (params) ->
    @calendar_events_url = params.calendar_events_url
    calendarTab = @$('.calendar-tab').closest('li')
    @openCalendar() if @$(calendarTab).hasClass('active')

  events: ->
    'shown.bs.tab .calendar-tab': 'openCalendar'

  openCalendar: (e) ->
    if MS.calendarView
      MS.calendarView.refresh()
    else
      MS.calendarView = new MS.Views.CalendarView({calendar_events_url: @calendar_events_url})
