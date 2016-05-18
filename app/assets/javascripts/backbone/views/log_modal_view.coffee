class MS.Views.LogModalView extends Backbone.View

  el: '#log-modal'

  events:
    'click [data-action="submit"]': 'submitForm'
    'ajax:success': 'ajaxSuccess'

  initialize: (params) ->
    @stepId = params.stepId

    if params.action == "add-log"
      @showNew(@stepId)
    else
      @showEdit(params.logId)

  showEdit: (logId) ->
    MS.loadingIndicator.show()
    $.get "/admin/project_logs/#{logId}/edit", (html) =>
      @replaceContent(html)

  showNew: (stepId) ->
    MS.loadingIndicator.show()
    $.get '/admin/project_logs/new', step_id: stepId, (html) =>
      @replaceContent(html)

  replaceContent: (html) ->
    @$el.find('.modal-content').html(html)
    new MS.Views.TranslationsView({
      el: @$('[data-content-translatable="log"]')
    })
    @$el.modal('show')
    MS.loadingIndicator.hide()

  submitForm: (e) ->
    e.preventDefault()
    @$el.find('form').submit()
    @$el.modal('hide')

  ajaxSuccess: (e, data) ->
    step = $(".timeline [data-step-id='#{@stepId}']")
    $(step).find('.step-logs').html(data).addClass('expanded')
