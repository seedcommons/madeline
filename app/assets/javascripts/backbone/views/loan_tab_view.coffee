class MS.Views.LoanTabView extends Backbone.View

  initialize: (params) ->
    @calEvents = params.calEvents
    calendarTab = @$('.calendar-tab').closest('li')
    @openCalendar() if @$(calendarTab).hasClass('active')

  events: ->
    'shown.bs.tab .calendar-tab': 'openCalendar'

  openCalendar: (e) ->
    @calView = new MS.Views.CalendarView({
      calEvents: @calEvents
    })

    # if !@calView
    #   @calView = new MS.Views.CalendarView({
    #     calEvents: @calEvents
    #   })
    # else
    #   @calView.rerenderEvents()
