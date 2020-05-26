class MS.Views.RichTextModalView extends Backbone.View

  el: '#rich-text-modal'

  initialize: (e, options) ->
    MS.loadingIndicator.show()
    @prepUnsavedChangesWarning()
    @clearModalContent()

    @question = e.currentTarget.closest('.question')

    questionContent = {
      label: @question.getElementsByClassName('question-label')[0].innerHTML,
      helpText: @question.getElementsByClassName('help-block')[0].innerHTML,
      answer: @question.getElementsByClassName('rt-answer')[0].innerHTML
    }

    @replaceModalContent(questionContent)

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

  replaceModalContent: (questionContent) ->
    @$el.find('.rtm-label').html(questionContent.label)
    @$el.find('.rtm-help').html(questionContent.helpText)
    @$el.find('.rtm-answer').summernote('code', questionContent.answer);
    @done = @showModal()

  showModal: () ->
    @$el.modal('show')
    MS.loadingIndicator.hide()

  updateResponse: ->
    newAnswer = @$el.find('.rtm-answer').summernote('code')
    newAnswer = newAnswer.trim()

    $(@question).find('.current-response-heading').removeClass('hidden')
    $(@question).find('.answer.no-response').removeClass('hidden')

    if newAnswer.length == 0
      newAnswer = ""
      $(@question).find('.current-response-heading').addClass('hidden')
    else
      $(@question).find('.answer.no-response').addClass('hidden')

    @question.getElementsByClassName('rt-answer')[0].innerHTML = newAnswer
    @question.getElementsByClassName('rt-response')[0].value = newAnswer

    @done = @updateSuccess()

  updateSuccess: ->
    @$el.modal('hide')
    $('#rt-changes-warning').removeClass('hidden')

  prepUnsavedChangesWarning: ->
    $('#rt-changes-warning').appendTo('.alerts')
