# Handles events on all media browser elements on the page.
# Controls the media modal (no more than one per page).
class MS.Views.MediaView extends Backbone.View

  el: 'body'

  events:
    'click .media-action.edit': 'showMediaModal'
    'click .media-action.new': 'showMediaModal'
    'click .media-action.delete': 'hideLogModal'
    'confirm:complete .media-action.delete': 'deleteItem'
    'click .media-modal .btn-primary': 'submitForm'
    'ajax:complete .media-modal form': 'submitComplete'
    'ajax:complete .media-action.proceed': 'deleteComplete'
    'click .media-action.cancel': 'hideModal'

  showMediaModal: (e) ->
    MS.loadingIndicator.show()
    e.preventDefault()
    link = e.currentTarget

    #@defineMediaVariables(link)s
    @mediaBox = @$(link).closest('.media-browser')
    mediaType = @mediaBox.data('media-type')
    @isLog = mediaType == 'ProjectLog' ? true : false
    @$('#log-modal').modal('hide') if @isLog

    $.get @$(link).attr('href'), (html) =>
      @$('.media-modal .modal-content').html(html)
      @$('.media-modal').modal('show')
      MS.loadingIndicator.hide()

  defineMediaVariables: (link) ->
    @mediaBox = @$(link).closest('.media-browser')
    mediaType = @mediaBox.data('media-type')
    @isLog = mediaType == 'ProjectLog' ? true : false
    @$('#log-modal').modal('hide') if @isLog

  hideModal: (e) ->
    e.preventDefault()
    @$('.media-modal').modal('hide')
    @$('#log-modal').modal('show') if @isLog

  hideLogModal: (e) ->
    e.preventDefault()
    link = e.currentTarget

    # @defineMediaVariables(link)
    @mediaBox = @$(link).closest('.media-browser')
    mediaType = @mediaBox.data('media-type')
    @isLog = mediaType == 'ProjectLog' ? true : false
    @$('#log-modal').modal('hide') if @isLog

  submitForm: ->
    MS.loadingIndicator.show()
    @$('.media-modal form').submit()

  submitComplete: (e, data) ->
    MS.loadingIndicator.hide()
    if parseInt(data.status) == 200 # data.status is sometimes a string, sometimes an int!?
      @$('.media-modal').modal('hide')
      @mediaBox.replaceWith(data.responseText)
      @$('#log-modal').modal('show') if @isLog
    else
      @$('.media-modal .modal-content').html(data.responseText)

  closeLogModal: (e) ->
    e.preventDefault()
    link = e.currentTarget
    @mediaBox = @$(link).closest('.media-browser')

    mediaType = @mediaBox.data('media-type')
    @isLog = mediaType == 'ProjectLog' ? true : false
    @$('#log-modal').modal('hide') if @isLog

  deleteItem: (e, response) ->
    e.preventDefault()
    link = e.currentTarget

    @mediaBox = @$(link).closest('.media-browser')
    mediaType = @mediaBox.data('media-type')
    @isLog = mediaType == 'ProjectLog' ? true : false

    $.post @$(link).attr('href'), {'_method': 'DELETE'}, (html) =>
      @deleteComplete(html)

  deleteComplete: (html) ->
    @mediaBox.replaceWith(html)
    @$('#log-modal').modal('show') if @isLog
