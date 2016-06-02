# Handles events on all media browser elements on the page.
# Controls the media modal (no more than one per page).
class MS.Views.MediaView extends Backbone.View

  el: 'body'

  events:
    'click .media-action.edit': 'showMediaModal'
    'click .media-action.new': 'showMediaModal'
    'click .media-action.cancel': 'hideMediaModal'
    'click .media-modal .btn-primary': 'submitForm'
    'ajax:complete .media-modal form': 'submitComplete'
    'click .media-action.delete': 'hideLogModal'
    'confirm:complete .media-action.delete': 'deleteItem'
    'ajax:complete .media-action.proceed': 'deleteComplete'

  defineMediaVariables: (link) ->
    @mediaBox = @$(link).closest('.media-browser')
    mediaType = @mediaBox.data('media-type')
    @isLog = mediaType == 'ProjectLog' ? true : false

  deleteComplete: (html) ->
    MS.loadingIndicator.hide()
    @mediaBox.replaceWith(html)
    @$('#log-modal').modal('show') if @isLog

  deleteItem: (e, response) ->
    e.preventDefault()
    link = e.currentTarget
    @defineMediaVariables(link)
    MS.loadingIndicator.show()

    $.post @$(link).attr('href'), {'_method': 'DELETE'}, (html) =>
      @deleteComplete(html)

  hideLogModal: (e) ->
    e.preventDefault()
    link = e.currentTarget
    @defineMediaVariables(link)
    @$('#log-modal').modal('hide') if @isLog

  hideMediaModal: (e) ->
    e.preventDefault()
    @$('.media-modal').modal('hide')
    @$('#log-modal').modal('show') if @isLog

  showMediaModal: (e) ->
    MS.loadingIndicator.show()
    e.preventDefault()
    link = e.currentTarget
    @defineMediaVariables(link)
    @$('#log-modal').modal('hide') if @isLog

    $.get @$(link).attr('href'), (html) =>
      @$('.media-modal .modal-content').html(html)
      @$('.media-modal').modal('show')
      MS.loadingIndicator.hide()

  submitComplete: (e, data) ->
    MS.loadingIndicator.hide()
    if parseInt(data.status) == 200 # data.status is sometimes a string, sometimes an int!?
      @$('.media-modal').modal('hide')
      @mediaBox.replaceWith(data.responseText)
      @$('#log-modal').modal('show') if @isLog
    else
      @$('.media-modal .modal-content').html(data.responseText)

  submitForm: ->
    MS.loadingIndicator.show()
    @$('.media-modal form').submit()
