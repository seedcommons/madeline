# Handles events on all media browser elements on the page.
# Controls the media modal (no more than one per page).
class MS.Views.MediaView extends Backbone.View

  el: 'body'

  events:
    'click .media-action.edit': 'showMediaModal'
    'click .media-action.new': 'showMediaModal'
    'click .media-modal .btn-primary': 'submitForm'
    'ajax:complete .media-modal form': 'submitComplete'
    'click .media-action.cancel': 'hideModal'

  hideModal: (e) ->
    e.preventDefault()
    @$('.media-modal').modal('hide')

  showMediaModal: (e) ->
    MS.loadingIndicator.show()
    e.preventDefault()
    link = e.currentTarget
    @mediaBox = @$(link).closest('.media-browser')

    $.get @$(link).attr('href'), (html) =>
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
      @mediaBox.replaceWith(data.responseText)
    else
      @$('.media-modal .modal-content').html(data.responseText)
