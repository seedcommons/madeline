# Common functions for calendars application-wide.
class MS.Views.CalendarView extends Backbone.View

  stepClick: (e) ->
    @stepModal.show(@$(e.currentTarget).data('step-id'), @refresh.bind(@))

  dayClick: (date) ->
    if @$el.find('#calendar[data-project-id]').length
      @stepModal.new(@$el.find('#calendar').data('project-id'), @refresh.bind(@),
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
        $.post("/admin/timeline_step_moves/#{stepId}/simple_move",
          _method: "PATCH"
          scheduled_start_date: event.start.format('YYYY-MM-DD'))
          .done => @refresh()

    else if event.model_type == 'BasicProject' || event.model_type == 'Loan'
      # We use a 1ms timeout so that fullCalendar can finish drawing the event in the new calendar cell.
      setTimeout =>
        if confirm(I18n.t("loan.move_date_confirm.body"))
          projectId = @$el.find('#calendar').data('project-id')
          $.post "/admin/projects/#{projectId}/change_date",
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
