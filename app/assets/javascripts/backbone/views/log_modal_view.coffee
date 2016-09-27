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
    formIsEmpty = true

    # Check to make sure summary is completed for at least one language
    # Only submit form if summary is present
    $form.find("[data-translatable='common.summary']").each ->
      if ($.trim($(this).val()) != '')
        $form.submit()
        @submitted = true
        formIsEmpty = false

    if formIsEmpty
      $form.find('.alert').show()
    else
      @$('.modal').modal('hide')

  submitSuccess: (e, data) ->
    MS.loadingIndicator.hide()
    @parentView.replaceWith(data)
