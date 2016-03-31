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
      this.load_loan_info(params.loan, params.calendar_type)
      this.load_project_steps(params.steps)
    else if (params.calendar_type == "main")
      this.load_main_calendar(params.loans, params.calendar_type)

  load_main_calendar: (loans, calendar_type) ->
    self = this

    $(loans).each (key, loan) ->
      self.load_loan_info(loan, calendar_type)

  load_loan_info: (loan, calendar_type) ->
    this.loan_start_event(loan, calendar_type)
    this.loan_end_event(loan, calendar_type)

    console.log(calendar_type)

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
      cal_item.allDay = true
      
      if (step.step_type_value == "milestone")
        cal_item.className = "cal-step cal-step-milestone"
      else
        cal_item.className = "cal-step"
      
      if step.completed_date
        cal_item.start = step.completed_date
      else
        cal_item.start = step.scheduled_date

      $('#calendar').fullCalendar( 'renderEvent', cal_item, stick: true );

      if (step.original_scheduled_date != cal_item.start)
        self.add_ghost_step(step)

  loan_start_event: (loan, calendar_type) ->
    cal_item = {}

    cal_item.start = loan.signing_date
    cal_item.id = "loan-" + loan.id + "-start"
    cal_item.className = "cal-loan cal-loan-start"
    cal_item.allDay = true

    if (calendar_type == "main")
      cal_item.title = "Start of " + loan.name
    else
      cal_item.title = "Project starts"

    $('#calendar').fullCalendar( 'renderEvent', cal_item, stick: true );

  loan_end_event: (loan, calendar_type) ->
    cal_item = {}

    cal_item.start = loan.target_end_date
    cal_item.id = "loan-" + loan.id + "-end"
    cal_item.className = "cal-loan cal-loan-end"
    cal_item.allDay = true

    if (calendar_type == "main")
      cal_item.title = "End of " + loan.name
    else
      cal_item.title = "Project ends"

    $('#calendar').fullCalendar( 'renderEvent', cal_item, stick: true );

  add_ghost_step: (step) ->
    cal_item = {}
    cal_item.id = "ghost-step-" + step.id
    cal_item.title = "Ghost Step"
    cal_item.start = step.original_scheduled_date
    cal_item.allDay = true

    if (step.step_type_value == "milestone")
      cal_item.className = "cal-ghost-step cal-step-milestone"
    else
      cal_item.className = "cal-ghost-step"

    $('#calendar').fullCalendar( 'renderEvent', cal_item, stick: true );
