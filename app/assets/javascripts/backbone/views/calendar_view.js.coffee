class MS.Views.CalendarView extends Backbone.View

  el: 'body'

  initialize: (params) ->
    # Initialize calendar
    $('#calendar').fullCalendar()

    this.render_cal_events(params.events)

  render_cal_events: (events) ->
    self = this

    $(events).each (key, cal_event) ->
      self.render_cal_event(cal_event)

  render_cal_event: (cal_item) ->
    $('#calendar').fullCalendar( 'renderEvent', cal_item, stick: true )
