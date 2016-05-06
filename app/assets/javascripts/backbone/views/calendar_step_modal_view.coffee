class MS.Views.CalendarStepModalView extends Backbone.View

  el: '#calendar-step-modal'

  initialize: (params) ->
    @context = params.context
    if params.id
      @id = params.id
      @showStep()
    else
      @loanId = params.loanId
      @showNewStep()

  events:
    'click a.action-delete': 'deleteStep'

  showStep: ->
    $.get '/admin/project_steps/' + @id, context: @context, (html) =>
      @replaceContent(html)

  showNewStep: ->
    $.get '/admin/project_steps/new', context: @context, loan_id: @loanId, (html) =>
      @replaceContent(html)

  replaceContent: (html) ->
    @$el.find('.modal-content').html(html)
    @$el.modal({show: true})
    MS.loadingIndicator.hide()

  deleteStep: ->
    @$el.modal('hide')
