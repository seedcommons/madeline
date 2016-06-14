class MS.Views.LogModalView extends Backbone.View

  initialize: (options) ->
    @parentView = options.parentView

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
    @$el.html(html)
    new MS.Views.TranslationsView(el: @$('[data-content-translatable="log"]'))
    @$('.modal').modal('show')
    MS.loadingIndicator.hide()

  submitForm: (e) ->
    e.preventDefault()
    @$('form').submit()
    @$('.modal').modal('hide')

  ajaxSuccess: (e, data) ->
    MS.loadingIndicator.hide()
    @parentView.replaceWith(data)

  expandContent: (e) ->
    e.preventDefault()
    link = e.currentTarget
    control = @$(link).data("control")
    selector = @$(link).closest('.language-block').find("[data-expandable='#{control}']")
    @$(selector).addClass('expanded')
    @$(link).addClass('hidden')
