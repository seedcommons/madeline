$ ->
  $('#choose-all').click (e) ->
    control_all(e)

  $('#check-all-ctrl').click (e) ->
    check_all(e)

  $('#uncheck-all-ctrl').click (e) ->
    uncheck_all(e)

  $('#check-completed-ctrl').click (e) ->
    uncheck_all(e)
    check_completed(e)

  $('#check-incomplete-ctrl').click (e) ->
    uncheck_all(e)
    check_incomplete(e)

  # Check or uncheck all items with master checkbox
  control_all = (e) ->
    control = e.currentTarget
    $inputs = $(control).closest(".timeline").find('.select-step')

    if ($(control)[0].checked == true)
      check_items($inputs)
    else
      uncheck_items($inputs)

  check_all = (e) ->
    control = e.currentTarget
    $inputs = $(control).closest(".timeline").find('.select-step')
    check_items($inputs)

    $master_checkbox = $(control).closest(".btn-group").find("#choose-all")
    check_items($master_checkbox)

  uncheck_all = (e) ->
    control = e.currentTarget
    $inputs = $(control).closest(".timeline").find('.select-step')
    uncheck_items($inputs)

    $master_checkbox = $(control).closest(".btn-group").find("#choose-all")
    uncheck_items($master_checkbox)

  check_completed = (e) ->
    control = e.currentTarget
    $inputs = $(control).closest(".timeline").find('.completed-item')
    check_items($inputs)

  check_incomplete = (e) ->
    control = e.currentTarget
    $inputs = $(control).closest(".timeline").find('.incomplete-item')
    check_items($inputs)

  check_items = (items) ->
    $(items).addClass('checked').attr('checked', "checked").prop("checked", true)

  uncheck_items = (items) ->
    $(items).removeClass('checked').attr('checked', false).prop("checked", false)
