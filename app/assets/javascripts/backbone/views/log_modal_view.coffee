class MS.Views.LogModalView extends Backbone.View

  initialize: (options) ->
    @parentView = options.parentView
    @submitted = false

  events:
    'click [data-action="submit"]': 'submitForm'
    'hidden.bs.modal': 'cancel'
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
    new MS.Views.TranslationsView(el: @$('[data-content-translatable="log"]'))
    @$('.modal').modal('show')
    MS.loadingIndicator.hide()

  submitForm: (e) ->
    e.preventDefault()
    @$('form').submit()
    @$('.modal').modal('hide')
    @submitted = true

  cancel: ->
    @destroySelf() unless @submitted

  ajaxSuccess: (e, data) ->
    MS.loadingIndicator.hide()
    @parentView.replaceWith(data)
    @destroySelf()

  destroySelf: ->
    @$el.remove()
