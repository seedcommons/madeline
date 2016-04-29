class MS.Views.CalendarStepModalView extends Backbone.View

  el: '.calendar'

  events:
    'click .cal-step': 'showStepModal'

  showStepModal: (e) ->
    calStep = e.currentTarget
    id = @$(calStep).attr('data-step-id')
    MS.loadingIndicator.show()
    $.get '/admin/project_steps/' + id, context: 'calendar', (html) =>
      @replaceContent(html)

  replaceContent: (html) ->
    @$('#calendar-step-modal').find('.modal-content').empty().append(html)
    @$('#calendar-step-modal').modal({show: true})
    MS.loadingIndicator.hide()
