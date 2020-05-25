class MS.Views.RichTextModalView extends Backbone.View

  el: '#rich-text-modal'

  initialize: (e, options) ->
    # console.log("Rich Text Modal View")
    # console.log(e)

    question = e.currentTarget.closest('.question')
    questionContent = {
      label: question.getElementsByClassName('question-label')[0].innerText,
      helpText: question.getElementsByClassName('help-block')[0].innerText,
      answer: question.getElementsByClassName('answer')[0].innerHTML
    }

    @replaceModalContent(questionContent)


  # events:

  replaceModalContent: (questionContent)->
    console.log(@$el)
    console.log(questionContent)
    console.log(@$el.find('rt-label'))
    @$el.find('.rt-label').text(questionContent.label)
    @$el.find('.rt-help').text(questionContent.helpText)
    @$el.find('.rt-answer').html(questionContent.answer)
    @$el.modal('show')

  # showModal:
