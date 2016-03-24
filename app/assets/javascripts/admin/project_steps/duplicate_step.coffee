$ ->
  # If custom repeat is selected, show hidden box

  $("input[name='repeat_duration']").change (e) ->
    item = e.currentTarget
    $repeat_options = $(item).closest("form").find(".repeat-options")

    if ($(item).val() == "custom_repeat")
      $repeat_options.removeClass("hidden")
    else
      $repeat_options.addClass("hidden")

  $("select[name='time_unit']").change (e) ->
    $item = $(e.currentTarget)
    $option = $item.find("option:selected")
    value = $option.val()

    $month_options = $item.closest("form").find(".month-options")

    if (value == "months")
      $month_options.removeClass("hidden")
    else
      $month_options.addClass("hidden")

  $(".num-of-occurences").click (e) ->
    check_radio(this)

  $(".date-end-of-occurences").click (e) ->
    check_radio(this)

  check_radio = (item) ->
    radio = $(item).find(".radio-item")
    $(radio).attr('checked', "checked").prop("checked", true)
