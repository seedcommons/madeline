$ ->
  $('#choose-all').click () ->
    $inputs = $(this).closest(".timeline form").find('.select-step')
    choose_all = $(this)[0].checked

    if (choose_all == true)
      $inputs.addClass('checked').attr('checked', "checked").prop("checked", true)
    else
      $inputs.removeClass('checked').attr('checked', false).prop("checked", false)

  # Function to check all, which receives items/item
    # check_items(items)

  # Function to uncheck all
    # uncheck_item(items)

  # Function specically for completed items
    # List of items will be completed items

  # Function specifically for uncompleted items

