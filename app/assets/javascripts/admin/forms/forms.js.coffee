$ ->
  $('.edit-action').click () ->
    $('.show-view').addClass('edit-view').removeClass('show-view')

  $('.show-action').click () ->
    $('.edit-view').addClass('show-view').removeClass('edit-view')

  $('.update-action').click (e) ->
    e.preventDefault()
