class MS.Views.TimelineSelectStepsView extends Backbone.View

  el: '#timeline-header'

  events: (params) ->
    'change .select-step': 'rememberChecked'
    'click #choose-all': 'controlAll'
    'click #check-all-ctrl': 'checkAll'
    'click #uncheck-all-ctrl': 'uncheckAll'
    'click #check-completed-ctrl': 'checkCompleted'
    'click #check-incomplete-ctrl': 'checkIncomplete'

  checkAll: () ->
    @.toggleAll(true)

  uncheckAll: () ->
    @.toggleAll(false)

  checkCompleted: () ->
    $inputs = @$el.find('.completed-item')
    @.toggleSubset(true, $inputs)

  checkIncomplete: () ->
    $inputs = @$el.find('.incomplete-item')
    @.toggleSubset(false, $inputs)

  toggleAll: (isChecked) ->
    $inputs = @$el.find('.select-step')
    @.toggle(isChecked, $inputs)

    $masterCheckbox = @$el.find('#choose-all')
    @.toggle(isChecked, $masterCheckbox)

  toggleSubset: (isChecked, $inputs) ->
    @.uncheckAll()

    @.toggle($inputs)

  toggle: (isChecked, $inputs) ->
    if (isChecked)
      @.checkItems($inputs)
    else
      @.uncheckItems($inputs)

    @.rememberChecked()

  checkItems: (items) ->
    $(items).addClass('checked').attr('checked', 'checked').prop('checked', true)

  uncheckItems: (items) ->
    $(items).removeClass('checked').attr('checked', false).prop('checked', false)

  # Check or uncheck all items with master checkbox
  controlAll: (e) ->
    control = e.currentTarget
    $inputs = @$el.find('.select-step')

    @.toggle(control.checked, $inputs)

  rememberChecked: () ->
    ids = []

    $('.select-step').each (index) ->
      if (@.checked)
        ids.push($(@).data('id'))

    $('#step-ids').attr('value', ids)
