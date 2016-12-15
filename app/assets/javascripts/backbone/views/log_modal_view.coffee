class MS.Views.LogModalView extends Backbone.View

  initialize: (options) ->
    # TODO: Remove @parentView stuff once old timeline goes away
    @parentView = options.parentView
    @submitted = false
    @done = (->) # Empty function

  events:
    'click [data-action="submit"]': 'submitForm'
    'ajax:success': 'submitSuccess'

  showEdit: (logId, stepId, done) ->
    MS.loadingIndicator.show()
    @stepId = stepId
    @done = done
    $.get "/admin/logs/#{logId}/edit", (html) =>
      @replaceContent(html)

  showNew: (stepId, done) ->
    MS.loadingIndicator.show()
    @stepId = stepId
    @done = done
    $.get '/admin/logs/new', step_id: @stepId, (html) =>
      @replaceContent(html)

  replaceContent: (html) ->
    @$el.html(html)
    new MS.Views.TranslationsView(el: @$('[data-content-translatable="project_log"]'))
    @$el.find('.empty-log-error').hide()
    @$('.modal').modal('show')
    MS.loadingIndicator.hide()

  submitForm: (e) ->
    e.preventDefault()
    $form = @$('form')
    submitted = @submitted

    # Check to make sure summary is completed for at least one language
    $form.find("[data-translatable='common.summary']").each ->
      if ($.trim($(this).val()) != '')
        submitted = true

    if submitted
      $form.submit()
      @$('.modal').modal('hide')
    else
      $form.find('.empty-log-error').show()

  submitSuccess: (e, data) ->
    MS.loadingIndicator.hide()
    if @parentView # TODO: Remove once old timeline goes away
      @parentView.replaceWith(data)
    else
      @done()
      @done = (->) # Reset to empty function.
