class MS.Views.DuplicateStepView extends Backbone.View

  events: (params) ->
    'change input[name="duplication[repeat_duration]"]': 'toggleRepeatOptions'
    'change select[name="duplication[time_unit]"]': 'toggleMonthOptions'
    'click .num-of-occurrences': 'checkRadio'
    'click .date-end-of-occurrences': 'checkRadio'
    'click .btn-primary': 'submit'
    'ajax:success': 'submitSuccess'

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

  submit: (e) ->
    @$('form').submit()
    MS.loadingIndicator.show()

  submitSuccess: (e, data) ->
    e.stopPropagation() # Don't want this to travel up to ProjectStepView

    # TODO: The below needs to be changed
    MS.timelineView.addSteps(data)

    @$el.modal('hide')
    MS.loadingIndicator.hide()
