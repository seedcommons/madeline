# Handles the modal that allows creation/editing of ProjectLogs
class MS.Views.LogFormModalView extends Backbone.View

  initialize: (options) ->
    # TODO: Remove @parentView stuff once old timeline goes away
    @parentView = options.parentView
    @done = (->) # Empty function

  events:
    'click [data-action="submit"]': 'submitForm'
    'ajax:complete': 'submitSuccess'
    'show.bs.modal .modal': 'addSummernoteToForm'

  showEdit: (logId, stepId, done) ->
    MS.loadingIndicator.show()
    @stepId = stepId
    @done = done
    $.get "/admin/logs/#{logId}/edit", (html) =>
      @replaceModal(html)

  showNew: (stepId, done) ->
    MS.loadingIndicator.show()
    @stepId = stepId
    @done = done
    $.get '/admin/logs/new', step_id: @stepId, (html) =>
      @replaceModal(html)

  replaceModal: (html) ->
    @$el.html(html)
    new MS.Views.TranslationsView(el: @$('[data-content-translatable="project_log"]'))
    @$el.find('.empty-log-error').hide()
    MS.loadingIndicator.hide()
    @$('.modal').modal('show')

  replaceContent: (html) ->
    @$el.find('.modal-content').html(html)
    new MS.Views.TranslationsView(el: @$('[data-content-translatable="project_log"]'))
    MS.loadingIndicator.hide()

  submitForm: ->
    MS.loadingIndicator.show()
    @$('form').submit()

  submitSuccess: (e, data) ->
    MS.loadingIndicator.hide()

    if @parentView # TODO: Remove once old timeline goes away
      @parentView.replaceWith(data)
    else
      if parseInt(data.status) == 200 # data.status is sometimes a string, sometimes an int!?
        @$('.modal').modal('hide')
        @updateLogSummaryInList(data.responseText)
        @done()
        @done = (->) # Reset to empty function.
      else
        @replaceContent(data.responseText)
        @addSummernoteToForm()

  updateLogSummaryInList: (dataResponse) ->
    # Update the log summary inside the timeline table step
    dataResponse = JSON.parse(dataResponse)
    summary = dataResponse['summary']['text']
    logId = dataResponse['logId']
    $("#timeline-table table .log-summary.project-step-item[data-log-id=#{logId}]").html(summary)

  addSummernoteToForm: ->
    @$('textarea.summernote').summernote({
      dialogsInBody: true,
      height: 150,
      toolbar: [
        ["style", ["bold", "italic", "underline", "clear"]],
        ["insert", ["table", "picture", "link", "video"]],
        ["para", ["ul", "ol", "paragraph"]]
      ]
    })
