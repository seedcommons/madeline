class MS.Views.RichTextModalView extends Backbone.View

  el: '#rich-text-modal'

  initialize: (options) ->
    @prepUnsavedChangesWarning()
    @eventService = options.eventService

  events:
    'click [data-action="submit"]': 'updateResponse'

  clearModalContent: ->
    @$el.find('.rtm-label').html('')
    @$el.find('.rtm-help').html('')
    @$el.find('.rtm-answer').html('')
    @done = @initializeSummernote()

  initializeSummernote: ->
    @$el.find('.rtm-answer').summernote('destroy')
    @$el.find('.rtm-answer').summernote({
      minHeight: 200,
      focus: true
    })

  prepForm: (e) ->
    MS.loadingIndicator.show()
    @clearModalContent()
    question = e.currentTarget.closest('.question')
    @$question = $(question)

    questionContent = {
      label: @$question.find('.question-label').html(),
      helpText: @$question.find('.help-block').html(),
      answer: @$question.find('.rt-answer').html()
    }

    @done = @replaceModalContent(questionContent)

  prepUnsavedChangesWarning: ->
    $('#rt-changes-warning').appendTo('.alerts')

  replaceModalContent: (questionContent) ->
    @$el.find('.rtm-label').html(questionContent.label)
    @$el.find('.rtm-help').html(questionContent.helpText)
    @$el.find('.rtm-answer').summernote('code', questionContent.answer)
    @done = @showModal()

  showModal: ->
    @$el.modal('show')
    MS.loadingIndicator.hide()

  updateResponse: ->
    newAnswer = @$el.find('.rtm-answer').summernote('code')
    newAnswer = newAnswer.trim()

    @$question.find('.answer.no-response').removeClass('hidden')

    if newAnswer.length == 0
      newAnswer = ""
      @$question.find('.current-response-heading').addClass('hidden')
    else
      @$question.find('.answer.no-response').addClass('hidden')

    @$question.find('.rt-answer').html(newAnswer)
    @$question.find('.rt-response').val(newAnswer)

    @done = @updateSuccess()

  updateSuccess: ->
    @$el.modal('hide')
    $('#rt-changes-warning').removeClass('hidden')
    $('#unsaved-changes-warning').removeClass('hidden')
    @eventService.trigger("rtAnswerChange", {q: @$question})
