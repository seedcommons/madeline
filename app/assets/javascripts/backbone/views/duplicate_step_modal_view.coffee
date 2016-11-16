class MS.Views.DuplicateStepModalView extends Backbone.View

  el: '#duplicate-step-modal'

  initialize: (params) ->
    new MS.Views.AutoLoadingIndicatorView()
    @done = (->) # Empty function

  events:
    'click .cancel': 'close'
    'click .submit': 'submitForm'
    'ajax:complete form': 'submitComplete'

  show: (e, id, done) ->
    e.preventDefault()
    e.stopPropagation()
    @done = done
    @stepId = id
    @loadContent("/admin/project_steps/#{@stepId}/show_duplicate?context=timeline_table")

  close: ->
    @$el.find('.modal').modal('hide')

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
    if parseInt(data.status) == 200
      @close()
      @runAndResetDoneCallback()
    else
      console.log(data)

  runAndResetDoneCallback: ->
    @done()
    @done = (->) # Reset to empty function.
