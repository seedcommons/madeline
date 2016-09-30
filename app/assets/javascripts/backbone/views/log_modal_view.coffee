class MS.Views.LogModalView extends Backbone.View

  initialize: (options) ->
    @parentView = options.parentView
    @submitted = false

  events:
    'click [data-action="submit"]': 'submitForm'
    'ajax:success': 'submitSuccess'

  showEdit: (logId, stepId) ->
    MS.loadingIndicator.show()
    @stepId = stepId
    $.get "/admin/project_logs/#{logId}/edit", (html) =>
      @replaceContent(html)

  showNew: (stepId) ->
    MS.loadingIndicator.show()
    @stepId = stepId
    $.get '/admin/project_logs/new', step_id: @stepId, (html) =>
      @replaceContent(html)

  replaceContent: (html) ->
    @$el.html(html)
    new MS.Views.TranslationsView(el: @$('[data-content-translatable="project_log"]'))
    @$el.find('.alert').hide()
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
      $form.find('.alert').show()

  submitSuccess: (e, data) ->
    MS.loadingIndicator.hide()
    @parentView.replaceWith(data)
