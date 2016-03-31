class MS.Views.CalendarView extends Backbone.View

  el: 'body'

  initialize: (params) ->
    # Initialize calendar
    $('#calendar').fullCalendar()

    # Render test date
    $('#calendar').fullCalendar('renderEvent', {
      title: "Test Event",
      date: new Date(),
      id: 9999
    });

    # Load calendar events based on calendar type
    if (params.calendar_type == "loan")
      this.load_loan_info(params.loan)
      this.load_project_steps(params.steps)
    else if (params.calendar_type == "main")
      this.load_main_calendar()

  load_main_calendar: (params) ->
    $('#calendar').fullCalendar()

  load_loan_info: () ->

  load_project_steps: (steps) ->
    # Test project step
    $('#calendar').fullCalendar('renderEvent', {
      title: "Project Step",
      date: new Date(),
      id: 9999
    });

    cal_events = []

    $(steps).each (key, step) ->
      cal_item = {}
      cal_item.id = step.id
      cal_item.title = "Project Step"
      
      if step.completed_date
        cal_item.start = step.completed_date
      else
        cal_item.start = step.scheduled_date

      $('#calendar').fullCalendar( 'renderEvent', cal_item );
