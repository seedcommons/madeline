class MS.Views.LoanTabView extends Backbone.View

  events: ->
    'click .tab': 'closeCalendar'
    'click .calendar-tab': 'openCalendar'

  closeCalendar: (e) ->
    $('#loan-calendar').css('display', 'none')

  openCalendar: (e) ->
    $('#loan-calendar').css('display', 'block')

    if !@calView
      @calView = new MS.Views.CalendarView()
    else
      # @calView.rerender()
      @calView = new MS.Views.CalendarView()
      cosole.log("calView exists")
