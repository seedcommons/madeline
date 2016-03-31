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
      id: 9999,
      className: "cal-step",
      allDay: true
    });

    self = this

    cal_events = []

    $(steps).each (key, step) ->
      # TODO: Replace original scheduled date with real data
      step.original_scheduled_date = step.created_at
      
      cal_item = {}
      cal_item.id = "step-" + step.id
      cal_item.title = "Project Step"
      cal_item.className = "cal-step"
      cal_item.allDay = true
      
      if step.completed_date
        cal_item.start = step.completed_date
      else
        cal_item.start = step.scheduled_date

      $('#calendar').fullCalendar( 'renderEvent', cal_item );

      if (step.original_scheduled_date != cal_item.start)
        self.add_ghost_step(step)

  loan_start_event: (loan) ->
    cal_item = {}

    cal_item.start = loan.signing_date
    cal_item.title = "Start: " + loan.name + "starts"
    cal_item.id = "loan-" + loan.id + "-start"
    cal_item.className = "cal-loan cal-loan-start"
    cal_item.allDay = true

    $('#calendar').fullCalendar( 'renderEvent', cal_item );

  loan_end_event: (loan) ->
    cal_item = {}

    cal_item.start = loan.target_end_date
    cal_item.title = "End: " + loan.name
    cal_item.id = "loan-" + loan.id + "-end"
    cal_item.className = "cal-loan cal-loan-end"
    cal_item.allDay = true

    $('#calendar').fullCalendar( 'renderEvent', cal_item );

  add_ghost_step: (step) ->
    cal_item = {}
    cal_item.id = "ghost-step-" + step.id
    cal_item.title = "Ghost Step"
    cal_item.start = step.original_scheduled_date
    cal_item.className = "cal-ghost-step"
    cal_item.allDay = true

    $('#calendar').fullCalendar( 'renderEvent', cal_item );
