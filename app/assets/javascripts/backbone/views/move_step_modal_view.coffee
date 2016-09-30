class MS.Views.MoveStepModalView extends Backbone.View

  initialize: (options) ->
    @context = options.context

  events:
    'click [data-action="submit"]': 'submitForm'
    'submit form': 'submitForm'
    'hidden.bs.modal': 'modalHidden'

  show: (stepId, daysShifted) ->
    @submitted = false
    MS.loadingIndicator.show()
    @stepId = stepId
    @deferred = jQuery.Deferred()
    params = "step_id=#{@stepId}&days_shifted=#{daysShifted}&context=#{@context}"
    $.get "/admin/timeline_step_moves/new?#{params}", (html) => @replaceContent(html)
    @deferred.promise()

  replaceContent: (html) ->
    @$el.html(html)
    @$el.find('.alert').hide()
    new MS.Views.TranslationsView(el: @$('[data-content-translatable="project_log"]'))
    @$('.modal').modal('show')
    MS.loadingIndicator.hide()

  submitForm: (e) ->
    e.preventDefault()
    MS.loadingIndicator.show()
    @submitted = true
    @$('.modal').modal('hide') # Form will be submitted when this is finished. See below.

  modalHidden: ->
    # If the form has been submitted, we need to wait for the modal to finish hiding before
    # actually submitting the data, else the modal doesn't properly hide in some cases.
    if @submitted
      form = @$('form')
      $.post(form.attr('action'), form.serialize()).done =>
        MS.loadingIndicator.hide()
        @deferred.resolve()

    # Otherwise, it means the user has cancelled the process, so reject the deferred.
    else
      @deferred.reject()
