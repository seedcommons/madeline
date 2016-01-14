$ ->
  $('.edit-action').click () ->
    $('.show-view').addClass('edit-view').removeClass('show-view')

  $('.show-action').click () ->
    $('.edit-view').addClass('show-view').removeClass('edit-view')

  $('.update-action').click (e) ->
    e.preventDefault()

    form = $(this).closest('form')
    id = $(form).attr('data-id')

    $.ajax '/',
      type: "PUT",
      url: "/admin/organizations/" + id,
      data: $(".organization-record").serialize(),
      success: (data) ->
        console.log("Updated")
