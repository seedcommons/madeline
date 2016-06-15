class MS.Views.MoveStepModalView extends Backbone.View

  initialize: (options) ->
    @parentView = options.parentView
    @context = options.context
    @cancelCallback = options.cancelCallback
    @daysShifted = options.daysShifted

  events:
    'click [data-action="submit"]': 'submitForm'
    'click [data-dismiss="modal"]': 'cancel'
    'ajax:success': 'ajaxSuccess'
    'hidden.bs.modal': 'destroySelf'

  show: (stepId) ->
    MS.loadingIndicator.show()
    @stepId = stepId
    params = "step_id=#{@stepId}&days_shifted=#{@daysShifted}&context=#{@context}"
    $.get "/admin/project_step_moves/new?#{params}", (html) =>
      @replaceContent(html)

  replaceContent: (html) ->
    @$el.html(html)
    new MS.Views.TranslationsView(el: @$('[data-content-translatable="log"]'))
    @$('.modal').modal('show')
    MS.loadingIndicator.hide()

  submitForm: (e) ->
    e.preventDefault()
    @$('form').submit()
    @$('.modal').modal('hide')

  ajaxSuccess: (e, data) ->
    MS.loadingIndicator.hide()
    #@parentView.replaceWith(data)

  cancel: ->
    @cancelCallback.call() if @cancelCallback

  destroySelf: ->
    @$el.remove()