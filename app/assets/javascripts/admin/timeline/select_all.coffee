$ ->
  $('#choose-all').click () ->
    $inputs = $(this).closest(".timeline form").find('.select-step')
    choose_all = $(this)[0].checked

    if (choose_all == true)
      $inputs.addClass('checked').attr('checked', "checked").prop("checked", true)
    else
      $inputs.removeClass('checked').attr('checked', false).prop("checked", false)
