class MS.Views.DuplicateStepView extends Backbone.View

  el: 'body'

  events: (params) ->
    "change input[name='repeat_duration']": 'toggle_repeat_options'
    "change select[name='time_unit']": 'toggle_month_options'
    "click .num-of-occurences": 'check_radio'
    "click .date-end-of-occurences": 'check_radio'

  toggle_repeat_options: (e) ->
    item = e.currentTarget
    $repeat_options = $(item).closest("form").find(".repeat-options")

    if ($(item).val() == "custom_repeat")
      $repeat_options.removeClass("hidden")
    else
      $repeat_options.addClass("hidden")

  toggle_month_options: (e) ->
    $item = $(e.currentTarget)
    $option = $item.find("option:selected")
    value = $option.val()

    $month_options = $item.closest("form").find(".month-options")

    if (value == "months")
      $month_options.removeClass("hidden")
    else
      $month_options.addClass("hidden")

  check_radio: (e) ->
    item = e.currentTarget
    radio = $(item).find(".radio-item")
    $(radio).attr('checked', "checked").prop("checked", true)
