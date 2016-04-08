class MS.Views.DuplicateStepView extends Backbone.View

  el: 'body'

  events: (params) ->
    'change input[name="repeat_duration"]': 'toggleRepeatOptions'
    'change select[name="time_unit"]': 'toggleMonthOptions'
    'click .num-of-occurences': 'checkRadio'
    'click .date-end-of-occurences': 'checkRadio'

  toggleRepeatOptions: (e) ->
    $item = $(e.currentTarget)
    $repeatOptions = $item.closest('form').find('.repeat-options')

    if ($item.val() == 'custom_repeat')
      $repeatOptions.removeClass('hidden')
    else
      $repeatOptions.addClass('hidden')

  toggleMonthOptions: (e) ->
    $item = $(e.currentTarget)
    $option = $item.find('option:selected')
    value = $option.val()

    $monthOptions = $item.closest('form').find('.month-options')

    if (value == 'months')
      $monthOptions.removeClass('hidden')
    else
      $monthOptions.addClass('hidden')

  checkRadio: (e) ->
    $item = $(e.currentTarget)
    $radio = $item.find('.radio-item')
    $radio.attr('checked', 'checked').prop('checked', true)
