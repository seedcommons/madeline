$ ->
  $('.update-action').click (e) ->
    form = $(this).closest('form')
    $(form).attr('method', 'PUT')
    data = $(".organization-record").serialize()
    location = window.location.href

    $.ajax
      method: 'PUT',
      url: location,
      data: data,
      success: (data) ->
        window.location.href = data
