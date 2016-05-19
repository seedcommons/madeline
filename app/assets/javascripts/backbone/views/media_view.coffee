# Handles clicks on media objects and manages the media modal.
class MS.Views.MediaView extends Backbone.View

  initialize: (params) ->
    @attachableType = params.attachableType
    @attachableId = params.attachableId

  events:
    'click a.edit': 'showMediaModal'
    'click a.new': 'showMediaModal'
    'click .media-modal .btn-primary': 'submitForm'
    'ajax:complete .media-modal form': 'submitComplete'

  showMediaModal: (e) ->
    MS.loadingIndicator.show()
    e.preventDefault()
    $.get @$(e.currentTarget).attr('href'), (html) =>
      @$('.media-modal .modal-content').html(html)
      @$('.media-modal').modal('show')
      MS.loadingIndicator.hide()

  submitForm: ->
    MS.loadingIndicator.show()
    @$('.media-modal form').submit()

  submitComplete: (e, data) ->
    MS.loadingIndicator.hide()
    if parseInt(data.status) == 200 # data.status is sometimes a string, sometimes an int!?
      @$('.media-modal').modal('hide')
      @$el.replaceWith(data.responseText)
    else
      @$('.media-modal .modal-content').html(data.responseText)
