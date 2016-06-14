class MS.Views.MoveStepModalView extends Backbone.View

  initialize: (options) ->
    @parentView = options.parentView

  events:
    'click [data-action="submit"]': 'submitForm'
    'ajax:success': 'ajaxSuccess'

  show: (stepId) ->
    MS.loadingIndicator.show()
    @stepId = stepId
    $.get "/admin/project_step_moves/new?step_id=#{@stepId}", (html) =>
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
    #@parentView.replaceWith(data)
