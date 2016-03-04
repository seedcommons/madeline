$ ->
  $('.edit-action').click () ->
    $('.show-view').addClass('edit-view').removeClass('show-view')
    $('.edit-tab').tab 'show'

  $('.show-action').click () ->
    $('.edit-view').addClass('show-view').removeClass('edit-view')
