class MS.Views.MoveStepModalView extends Backbone.View

  initialize: (options) ->
    @context = options.context
    @submitted = false

  events:
    'click [data-action="submit"]': 'submitForm'
    'hidden.bs.modal': 'cancel'
    'ajax:success form': 'submitSuccess'

  show: (stepId, daysShifted) ->
    MS.loadingIndicator.show()
    @stepId = stepId
    @deferred = jQuery.Deferred()
    params = "step_id=#{@stepId}&days_shifted=#{daysShifted}&context=#{@context}"
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
    @$('.modal').modal('hide')
    @$('form').submit()
    @submitted = true

  cancel: ->
    unless @submitted
      @deferred.reject()

  submitSuccess: (e, data) ->
    e.stopPropagation()
    MS.loadingIndicator.hide()
    @deferred.resolve(data)
