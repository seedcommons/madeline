$ ->
  $('.edit-action').click () ->
    $('.show-view').addClass('edit-view').removeClass('show-view')

  $('.show-action').click () ->
    $('.edit-view').addClass('show-view').removeClass('edit-view')

  $('.update-action').click (e) ->
    e.preventDefault()

    form = $(this).closest('form')
    id = $(form).attr('data-id')
    $(form).attr('method', 'put')
    data = $(".organization-record").serialize()
    location = window.location.href

    $.ajax
      method: 'PUT',
      url: location,
      data: data,
      success: (data) ->
        console.log("Updated")
        window.location.href = data
      error: (data) ->
        console.log(data)
