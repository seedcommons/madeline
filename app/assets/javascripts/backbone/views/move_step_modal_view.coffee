class MS.Views.MoveStepModalView extends Backbone.View

  initialize: (options) ->
    @parentView = options.parentView
    @context = options.context
    @daysShifted = options.daysShifted
    @deferred = jQuery.Deferred()
    @submitted = false

  events:
    'click [data-action="submit"]': 'submitForm'
    'hidden.bs.modal': 'cancel'
    'ajax:success form': 'submitSuccess'

  show: (stepId) ->
    MS.loadingIndicator.show()
    @stepId = stepId
    params = "step_id=#{@stepId}&days_shifted=#{@daysShifted}&context=#{@context}"
    $.get "/admin/project_step_moves/new?#{params}", (html) => @replaceContent(html)
    @deferred.promise()

  replaceContent: (html) ->
    @$el.html(html)
    new MS.Views.TranslationsView(el: @$('[data-content-translatable="log"]'))
    @$('.modal').modal('show')
    MS.loadingIndicator.hide()

  submitForm: (e) ->
    e.preventDefault()
    MS.loadingIndicator.show()
    @$('form').submit()
    @$('.modal').modal('hide')
    @submitted = true

  cancel: ->
    unless @submitted
      @deferred.reject()
      @destroySelf()

  submitSuccess: (e, data) ->
    MS.loadingIndicator.hide()
    @deferred.resolve(data)
    @destroySelf()

  destroySelf: ->
    @$el.remove()