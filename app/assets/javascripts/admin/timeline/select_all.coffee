$ ->
  $('#choose-all').click () ->
    control_all()

  $('#check-all-ctrl').click () ->
    check_all()

  $('#uncheck-all-ctrl').click () ->
    uncheck_all()

  $('#check-completed-ctrl').click () ->
    uncheck_all()
    check_completed()

  $('#check-incomplete-ctrl').click () ->
    uncheck_all()
    check_incomplete()

  # Check or uncheck all items with master checkbox
  control_all = () ->
    control = event.currentTarget
    $inputs = $(control).closest(".timeline form").find('.select-step')
    choose_all = $(control)[0].checked

    if (choose_all == true)
      check_items($inputs)
    else
      uncheck_items($inputs)

  check_all = () ->
    control = event.currentTarget
    $inputs = $(control).closest(".timeline form").find('.select-step')
    check_items($inputs)

  uncheck_all = () ->
    control = event.currentTarget
    $inputs = $(control).closest(".timeline form").find('.select-step')
    uncheck_items($inputs)

  check_completed = () ->
    control = event.currentTarget
    $inputs = $(control).closest(".timeline form").find('.completed-item')
    check_items($inputs)

  check_incomplete = () ->
    control = event.currentTarget
    $inputs = $(control).closest(".timeline form").find('.incomplete-item')
    check_items($inputs)

  check_items = (items) ->
    $(items).addClass('checked').attr('checked', "checked").prop("checked", true)

  uncheck_items = (items) ->
    $(items).removeClass('checked').attr('checked', false).prop("checked", false)
