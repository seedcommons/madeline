class MS.Views.DuplicateStepModalView extends Backbone.View

  el: '#duplicate-step-modal'

  initialize: (params) ->
    new MS.Views.AutoLoadingIndicatorView()
    @done = (->) # Empty function

  events:
    'click .cancel': 'close'
    'click .submit': 'submitForm'
    'ajax:complete form': 'submitComplete'

  show: (e, id) ->
    e.preventDefault()
    e.stopPropagation()
    @stepId = id
    @loadContent("/admin/project_steps/#{@stepId}/show_duplicate?context=timeline_table")

  close: ->
    @modal.modal('hide')

  loadContent: (url) ->
    $.get url, (html) =>
      @replaceContent(html)

  replaceContent: (html) ->
    @$el.html(html)
    @$el.find('.modal').modal('show')

  submitForm: ->
    @$('form').submit()

  submitComplete: (e, data) ->
    e.stopPropagation()
    console.log(data)
    @$el.find('.modal').modal('hide')
