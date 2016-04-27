class MS.Views.LoanTabView extends Backbone.View

  initialize: (params) ->
    @calEvents = params.calEvents
    console.log(@calEvents)

  events: ->
    'click .tab': 'closeCalendar'
    'click .calendar-tab': 'openCalendar'

  closeCalendar: (e) ->
    $('#loan-calendar').css('display', 'none')

  openCalendar: (e) ->
    $('#loan-calendar').css('display', 'block')

    @calView = new MS.Views.CalendarView()

    # if !@calView
    #   @calView = new MS.Views.CalendarView({
    #     calEvents: @calEvents
    #   })
    # else
    #   @calView.rerenderEvents()
