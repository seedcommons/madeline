$ ->
  $('#choose-all').click () ->
    control_all(this)

  # Check or uncheck all items
  control_all = (control) ->
    $inputs = $(control).closest(".timeline form").find('.select-step')
    choose_all = $(control)[0].checked

    if (choose_all == true)
      check_items($inputs)
    else
      uncheck_items($inputs)

  check_items = (items) ->
    $(items).addClass('checked').attr('checked', "checked").prop("checked", true)

  uncheck_items = (items) ->
    $(items).removeClass('checked').attr('checked', false).prop("checked", false)

  # Function to check all, which receives items/item
    # check_items(items)

  # Function to uncheck all
    # uncheck_item(items)

  # Function specically for completed items
    # List of items will be completed items

  # Function specifically for uncompleted items

