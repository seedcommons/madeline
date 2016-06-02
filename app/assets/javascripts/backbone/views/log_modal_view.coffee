class MS.Views.LogModalView extends Backbone.View

  initialize: (options) ->
    @parentView = options.parentView

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
    @$('.modal-content').html(html)
    new MS.Views.TranslationsView(el: @$('[data-content-translatable="log"]'))
    @$el.modal('show')
    MS.loadingIndicator.hide()

  submitForm: (e) ->
    e.preventDefault()
    @$('form').submit()
    @$el.modal('hide')

  ajaxSuccess: (e, data) ->
    @parentView.replaceWith(data)

  expandContent: (e) ->
    e.preventDefault()
    link = e.currentTarget
    control = @$(link).data("control")
    selector = @$(link).closest('.language-block').find("[data-expandable='#{control}']")
    @$(selector).addClass('expanded')
    @$(link).addClass('hidden')
