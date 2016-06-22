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
    'click .media-action.delete': 'deleteItem'
    'confirm:complete .media-action.delete': 'deleteConfirm'
    'ajax:complete .media-action.proceed': 'deleteComplete'

  defineMediaVariables: (link) ->
    @mediaBox = @$(link).closest('.media-browser')
    mediaType = @mediaBox.data('media-type')

  deleteItem: (e) ->
    # Need to make sure we don't really follow the delete link.
    # Doing the actual delete is handled once the link is confirmed.
    e.preventDefault()

  deleteConfirm: (e, response) ->
    e.preventDefault()
    link = e.currentTarget
    @defineMediaVariables(link)
    MS.loadingIndicator.show()

    $.post @$(link).attr('href'), {'_method': 'DELETE'}, (html) =>
      @deleteComplete(html)

  deleteComplete: (html) ->
    MS.loadingIndicator.hide()
    @mediaBox.replaceWith(html)

  hideMediaModal: (e) ->
    e.preventDefault()
    @$('.media-modal').modal('hide')

  showMediaModal: (e) ->
    MS.loadingIndicator.show()
    e.preventDefault()
    link = e.currentTarget
    @defineMediaVariables(link)

    $.get @$(link).attr('href'), (html) =>
      @$('.media-modal .modal-content').html(html)
      @$('.media-modal').modal('show')
      new MS.Views.TranslationsView(el: @$('[data-content-translatable="media"]'));
      MS.loadingIndicator.hide()

  submitComplete: (e, data) ->
    MS.loadingIndicator.hide()
    if parseInt(data.status) == 200 # data.status is sometimes a string, sometimes an int!?
      @$('.media-modal').modal('hide')
      @mediaBox.replaceWith(data.responseText)
    else
      @$('.media-modal .modal-content').html(data.responseText)

  submitForm: ->
    MS.loadingIndicator.show()
    @$('.media-modal form').submit()
