class MS.Views.RichTextModalView extends Backbone.View

  el: '#rich-text-modal'

  initialize: (e, options) ->
    question = e.currentTarget.closest('.question')
    questionContent = {
      label: question.getElementsByClassName('question-label')[0].innerText,
      helpText: question.getElementsByClassName('help-block')[0].innerText,
      answer: question.getElementsByClassName('answer')[0].innerHTML
    }

    @showModal(questionContent)

  # events:

  initializeSummernote: ->
    @$el.find('.rt-answer').summernote()

  replaceModalContent: (questionContent) ->
    @$el.find('.rt-label').text(questionContent.label)
    @$el.find('.rt-help').text(questionContent.helpText)
    @$el.find('.rt-answer').html(questionContent.answer)

  showModal: (questionContent) ->
    @replaceModalContent(questionContent)
    @initializeSummernote()
    @$el.modal('show')
