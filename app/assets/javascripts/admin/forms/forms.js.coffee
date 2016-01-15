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
    dataarray = $(".organization-record").serializeArray()
    location = window.location.href

    $.ajax
      method: 'PUT',
      url: location,
      data: data,
      success: (data) ->
        console.log("Updated")
        console.log(data)
      error: (data) ->
        console.log("Error")
        console.log(data)
