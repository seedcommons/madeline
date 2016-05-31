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

  showMediaModal: (e) ->
    MS.loadingIndicator.show()
    e.preventDefault()
    link = e.currentTarget
    @mediaBox = @$(link).closest('.media-browser')
    @mediaType = @mediaBox.data('media-type')

    if @mediaType == 'ProjectLog'
      @$('#log-modal').modal('hide')

    $.get @$(link).attr('href'), (html) =>
      @$('.media-modal .modal-content').html(html)
      @$('.media-modal').modal('show')
      MS.loadingIndicator.hide()

  hideModal: (e) ->
    e.preventDefault()
    @$('.media-modal').modal('hide')

    if @mediaType == 'ProjectLog'
      @$('#log-modal').modal('show')

  submitForm: ->
    MS.loadingIndicator.show()
    @$('.media-modal form').submit()

  submitComplete: (e, data) ->
    MS.loadingIndicator.hide()
    if parseInt(data.status) == 200 # data.status is sometimes a string, sometimes an int!?
      @$('.media-modal').modal('hide')
      @mediaBox.replaceWith(data.responseText)

      if @mediaType == 'ProjectLog'
        @$('#log-modal').modal('show')
    else
      @$('.media-modal .modal-content').html(data.responseText)
