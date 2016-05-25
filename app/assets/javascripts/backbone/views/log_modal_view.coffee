class MS.Views.LogModalView extends Backbone.View

  el: '#log-modal'

  events:
    'click [data-action="submit"]': 'submitForm'
    'ajax:success': 'ajaxSuccess'
    'click [data-control]': 'expandContent'

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
    $(step).find('.step-logs').replaceWith(data)
    $(step).find('.step-logs').addClass('expanded')

  expandContent: (e) ->
    e.preventDefault()
    link = e.currentTarget
    control = @$(link).data("control")
    selector = @$(link).closest('.language-block').find("[data-expandable='#{control}']")
    @$(selector).addClass('expanded')
    @$(link).addClass('hidden')
