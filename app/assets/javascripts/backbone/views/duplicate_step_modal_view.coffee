class MS.Views.DuplicateStepModalView extends Backbone.View

  el: '#duplicate-step-modal'

  initialize: (params) ->
    new MS.Views.AutoLoadingIndicatorView()
    @done = (->) # Empty function

  events:
    'click .cancel': 'close'
    'click .submit': 'submitForm'
    'ajax:complete form': 'submitComplete'
    'change input[name="duplication[repeat_duration]"]': 'toggleRepeatOptions'
    'change select[name="duplication[time_unit]"]': 'toggleMonthOptions'
    'click .num-of-occurrences': 'checkRadio'
    'click .date-end-of-occurrences': 'checkRadio'

  show: (e, id, done) ->
    e.preventDefault() # Prevents timeline from reloading
    @done = done
    @stepId = id
    @loadContent("/admin/project_steps/#{@stepId}/show_duplicate?context=timeline_table")

  close: ->
    @$el.find('.modal').modal('hide')

  loadContent: (url) ->
    $.get url, (html) =>
      @replaceContent(html)

  replaceContent: (html) ->
    @$el.html(html)
    @$el.find('.modal').modal('show')

  submitForm: ->
    @$('form').submit()

  submitComplete: (e, data) ->
    @close()
    @runAndResetDoneCallback()

  runAndResetDoneCallback: ->
    @done()
    @done = (->) # Reset to empty function.

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
