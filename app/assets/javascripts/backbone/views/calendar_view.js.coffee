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
      this.load_main_calendar(params.loans)

  load_main_calendar: (loans) ->
    self = this

    $(loans).each (key, loan) ->
      self.load_loan_info(loan)

  load_loan_info: (loan) ->
    this.loan_start_event(loan)
    this.loan_end_event(loan)

  load_project_steps: (steps) ->
    # Test project step
    $('#calendar').fullCalendar('renderEvent', {
      title: "Test Step",
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

  loan_start_event: (loan) ->
    cal_item = {}

    cal_item.start = loan.signing_date
    cal_item.title = "Start: " + loan.name + "starts"
    cal_item.id = "loan-" + loan.id + "-start"

    $('#calendar').fullCalendar( 'renderEvent', cal_item );

  loan_end_event: (loan) ->
    cal_item = {}

    cal_item.start = loan.target_end_date
    cal_item.title = "End: " + loan.name
    cal_item.id = "loan-" + loan.id + "-end"

    $('#calendar').fullCalendar( 'renderEvent', cal_item );

