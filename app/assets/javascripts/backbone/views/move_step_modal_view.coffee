class MS.Views.MoveStepModalView extends Backbone.View

  initialize: (options) ->
    @context = options.context

  events:
    'click [data-action="submit"]': 'submitForm'
    'ajax:complete': 'submitSuccess'
    'hidden.bs.modal': 'modalHidden'

  show: (stepId, daysShifted) ->
    @submitted = false
    MS.loadingIndicator.show()
    @stepId = stepId
    @deferred = jQuery.Deferred()
    params = "step_id=#{@stepId}&days_shifted=#{daysShifted}&context=#{@context}"
    $.get "/admin/timeline_step_moves/new?#{params}", (html) => @replaceContent(html, 'show')
    @deferred.promise()

  replaceContent: (html, event) ->
    # Replace only the body if this is due to a validation fail
    if event == 'validation'
      @$('.modal-body').html($(html).find('.modal-body').html())
    else
      @$el.html(html)
      @$('.modal').modal('show')
    new MS.Views.TranslationsView(el: @$('[data-content-translatable="project_log"]'))
    MS.loadingIndicator.hide()

  submitForm: (e) ->
    MS.loadingIndicator.show()
    @$('form').submit()

  submitSuccess: (e, data) ->
    MS.loadingIndicator.hide()

    if parseInt(data.status) == 200 # data.status is sometimes a string, sometimes an int!?
      @$('.modal').modal('hide')
      @submitted = true
      @deferred.resolve()
    else
      @replaceContent(data.responseText, 'validation')

  modalHidden: ->
    # If not submitted, it means the user has cancelled the process, so reject the deferred.
    @deferred.reject() unless @submitted
