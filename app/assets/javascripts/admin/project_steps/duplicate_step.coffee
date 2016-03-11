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
    $week_options = $item.closest("form").find(".week-options")

    if (value == "weeks")
      $week_options.removeClass("hidden")
      $month_options.addClass("hidden")
    else if (value == "months")
      $week_options.addClass("hidden")
      $month_options.removeClass("hidden")
    else
      $week_options.addClass("hidden")
      $month_options.addClass("hidden")
