class MS.Views.CalendarStepModalView extends Backbone.View

  el: '.calendar'

  events:
    'click .cal-step': 'showStepModal'

  showStepModal: (e) ->
    # calStep = e.currentTarget
    # id = @$(calStep).attr('data-step-id')
    # selector = '.step[data-step-id=' + id + ']'
    # projectStep = $('.project-steps').find(selector)
    # color = $(projectStep).attr('data-color')
    # projectStepContent = $(projectStep).clone()
    # title = $(projectStep).find('.title-text').html()
    #
    # @$('#calendar-step-modal').find('.modal-body').empty().append(projectStepContent)
    # @$('#calendar-step-modal').find('.modal-title').empty().append(title)
    # calendarStep = @$('#calendar-step-modal').find('.modal-body').find('.step')
    # @$('#calendar-step-modal').find('.modal-content').css('border', '2px solid ' + color)

    @$('#calendar-step-modal').modal({show: true})
