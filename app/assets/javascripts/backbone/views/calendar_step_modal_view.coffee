class MS.Views.CalendarStepModalView extends Backbone.View

  el: '#calendar-step-modal'

  initialize: (params) ->
    @context = params.context
    if params.id
      @id = params.id
      @showStep()
    else
      @projectId = params.projectId
      @date = params.date
      @showNewStep()

  events:
    'click .action-delete': 'hideModal'
    'click .cancel': 'hideModal'

  showStep: ->
    $.get "/admin/project_steps/#{@id}", context: @context, (html) =>
      @replaceContent(html)

  showNewStep: ->
    $.get '/admin/project_steps/new', context: @context, project_id: @projectId, date: @date, (html) =>
      @replaceContent(html)

  replaceContent: (html) ->
    @$el.find('.modal-content').html(html)
    @$el.modal('show')
    MS.loadingIndicator.hide()

  hideModal: ->
    @$el.modal('hide')
