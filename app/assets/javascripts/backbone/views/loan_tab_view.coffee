class MS.Views.LoanTabView extends Backbone.View

  events: (params) ->
    'click .calendar-tab': 'openCalendar'

  openCalendar: () ->
    console.log("You tried to open the calendar")

    if !@calView
      @calView = new MS.Views.CalendarView()
    else
      # @calView.rerender()
      cosole.log("calView exists")
