class MS.Views.LoanTabView extends Backbone.View

  initialize: (params) ->
    @calendar_events_url = params.calendar_events_url
    @loanId = params.loanId

    @openCalendar() if @$('.calendar-tab').closest('li').hasClass('active')
    @loadSteps() if @$('.timeline-tab').closest('li').hasClass('active')

  events: ->
    'shown.bs.tab .calendar-tab': 'openCalendar'
    'shown.bs.tab .timeline-tab': 'loadSteps'

  openCalendar: (e) ->
    if MS.calendarView
      MS.calendarView.refresh()
    else
      MS.calendarView = new MS.Views.CalendarView({calendar_events_url: @calendar_events_url})

  loadSteps: ->
    if MS.timelineView
      MS.timelineView.refreshSteps()
    else
      MS.timelineView = new MS.Views.TimelineView({loanId: @loanId})