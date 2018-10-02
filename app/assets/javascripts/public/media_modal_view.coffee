# For public loans
class MS.Views.MediaModalView extends Backbone.View

  events: ->
    'click figure.thumbnail': 'open'

  open: (e) ->
    # Open image inside a modal
    $media_item = @$(e.currentTarget)
    url = $media_item.data('url')
    caption = $media_item.find('.full-caption').html()
    $('#mediaModal').find('img').attr('src', url)
    $('#mediaModal').find('.modal-title').html(caption)
    $('#mediaModal').modal('show')
