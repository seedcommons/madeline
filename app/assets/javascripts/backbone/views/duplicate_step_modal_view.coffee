class MS.Views.DuplicateStepModalView extends Backbone.View

  el: '#duplicate-step-modal'

  show: (e, id) ->
    e.preventDefault()
    e.stopPropagation()
    @stepId = id
    @loadContent("/admin/project_steps/#{@stepId}/show_duplicate")

  close: ->
    @modal.modal('hide')

  loadContent: (url) ->
    $.get url, (html) =>
      @replaceContent(html)

  replaceContent: (html) ->
    @$el.html(html)
    @$el.find('.modal').modal('show')
