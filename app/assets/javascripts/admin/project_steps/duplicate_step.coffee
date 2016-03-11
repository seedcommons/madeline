$ ->
  # If custom repeat is selected, show hidden box

  $("input[name='repeat-duration']").change (e) ->
    item = e.currentTarget
    $repeat_options = $(item).closest("form").find(".repeat-options")

    if ($(item).val() == "custom-repeat")
      $repeat_options.removeClass("hidden")
    else
      $repeat_options.addClass("hidden")
