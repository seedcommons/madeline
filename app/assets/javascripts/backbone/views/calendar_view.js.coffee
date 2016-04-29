class MS.Views.CalendarView extends Backbone.View

  el: '.calendar'

  initialize: (params) ->
    # Initialize calendar

    @$calendar = @$('#calendar')

    @$calendar.fullCalendar({
      # Changes the default event render to load in html rather than title only
      eventRender: (calEvent, element) ->
        element.find('.fc-title').html(calEvent.title)

      customButtons: {
        legend: {
          text: 'Legend'
        }
      },
      header: {
        left: 'prev,next today',
        center: 'title',
        right: 'month,agendaWeek legend'
      }
    })

    @renderLegend()
    @renderCalEvents(params.calEvents)

  events:
    'click .cal-step': 'showStepModal'

  renderCalEvents: (calEvents) ->
    $(calEvents).each (key, calEvent) =>
      this.renderCalEvent(calEvent)

  renderCalEvent: (calItem) ->
    @$calendar.fullCalendar('renderEvent', calItem, stick: true)

  rerenderEvents: (e) ->
    @$calendar.fullCalendar('rerenderEvents')

  renderLegend: (e) ->
    $('[data-toggle="popover"]').popover()
    popoverContent = @$('#legend-content').html()

    @$('.fc-legend-button').popover({
      'content': popoverContent,
      'html': true,
      'placement': 'left',
      'toggle': 'popover',
      title: 'Legend'
    })

  showStepModal: (e) ->
    calStep = e.currentTarget
    id = @$(calStep).attr('data-step-id')
    selector = '.step[data-step-id=' + id + ']'
    projectStep = $('.project-steps').find(selector)
    color = $(projectStep).attr('data-color')
    projectStepContent = $(projectStep).clone()
    title = $(projectStep).find('.title-text').html()

    @$('#calendar-step-modal').find('.modal-body').empty().append(projectStepContent)
    @$('#calendar-step-modal').find('.modal-title').empty().append(title)
    calendarStep = @$('#calendar-step-modal').find('.modal-body').find('.step')
    @$('#calendar-step-modal').modal({show: true})
    @$('#calendar-step-modal').find('.modal-content').css('border', '2px solid ' + color)

    new MS.Views.ProjectStepView({
      el: @$(calendarStep)
    })
