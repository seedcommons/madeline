class MS.Views.RichTextModalView extends Backbone.View

  el: '#rich-text-modal'

  initialize: (e, options) ->
    console.log("Rich Text Modal View")
    console.log(e)

    question = e.currentTarget.closest('.question')
    # questionLabel = question.getElementsByClassName('question-label')[0].innerText
    # questionHelpText = question.getElementsByClassName('help-block')[0].innerText
    # answer = question.getElementsByClassName('answer')[0].innerHTML
    questionContent = {
      label: question.getElementsByClassName('question-label')[0].innerText,
      helpText: question.getElementsByClassName('help-block')[0].innerText,
      answer: question.getElementsByClassName('answer')[0].innerHTML
    }
    # console.log(question)
    # console.log(questionLabel)
    # console.log(questionHelpText)

    @replaceModalContent(questionContent)
    @$el.modal('show')

  # events:

  replaceModalContent: (questionContent)->
    console.log(questionContent)
    # el.find("rt-question-label")

  # showModal:
