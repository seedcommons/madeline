class MS.Views.CalendarView extends Backbone.View

  el: '.calendar'

  initialize: (params) ->
    # Initialize calendar
    @$calendar = @$('#calendar')
    @stepModal = params.stepModal

    @$calendar.fullCalendar
      # Changes the default event render to load in html rather than title only
      eventRender: @eventRender.bind(this)
      eventDrop: @eventDrop.bind(this)
      loading: @loading.bind(this)
      events: params.calendarEventsUrl
      height: 'auto'
      lang: params.locale
      customButtons:
        legend:
          text: I18n.t('calendar.legend', locale: params.locale)
      header:
        left: 'prev,next today'
        center: 'title'
        right: 'month,basicWeek legend'
      allDayDefault: true
      dayClick: @dayClick.bind(this)

    @renderLegend()

  events:
    'click .cal-step': 'stepClick'

  stepClick: (e) ->
    @stepModal.show(@$(e.currentTarget).data('step-id'), @refresh.bind(@))

  dayClick: (date) ->
    if @$el.find('.loan-calendar').length
      @stepModal.new(@$el.find('.loan-calendar').data('loan-id'), @refresh.bind(@),
        date: date.format('YYYY-MM-DD'))

  eventRender: (calEvent) -> calEvent.html

  eventDrop: (event, delta, revertFunc) ->
    if event.model_type == 'ProjectStep'
      if event.is_finalized
        unless @moveStepModalView
          @moveStepModalView = new MS.Views.MoveStepModalView
            el: $("<div>").appendTo(@$el)
            context: 'calendar_drag'

        @moveStepModalView.show(event.model_id, delta.days())
        .done => @refresh()
        .fail => revertFunc()
      else
        stepId = event.model_id
        $.post "/admin/timeline_step_moves/#{stepId}/simple_move",
          _method: "PATCH"
          scheduled_start_date: event.start.format('YYYY-MM-DD')

    else if event.model_type == 'Loan'
      # We use a 1ms timeout so that fullCalendar can finish drawing the event in the new calendar cell.
      setTimeout =>
        if confirm(I18n.t("loan.move_date_confirm.body"))
          loanId = @$el.find('.loan-calendar').data('loan-id')
          $.post "/admin/loans/#{loanId}/change_date",
            _method: "PATCH"
            which_date: event.event_type
            new_date: event.start.format('YYYY-MM-DD')
        else
          revertFunc()
      ,1


  loading: (isLoading) ->
    MS.loadingIndicator[if isLoading then 'show' else 'hide']()

  renderLegend: (e) ->
    # We use the .ms-popover class with trigger: manual. This is handled in ApplicationView.
    @$('.fc-legend-button').addClass('ms-popover').popover
      content: @$('#legend-content').html()
      html: true
      placement: 'left'
      toggle: 'popover'
      title: 'Legend'
      trigger: 'manual'

  refresh: (e) ->
    @$calendar.fullCalendar('refetchEvents')
