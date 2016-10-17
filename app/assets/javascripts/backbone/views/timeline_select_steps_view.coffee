class MS.Views.TimelineSelectStepsView extends Backbone.View

  el: '#timeline-header'

  events: (params) ->
    'change .select-step': 'rememberChecked'
    'click #choose-all': 'controlAll'
    'click #check-all-ctrl': 'checkAll'
    'click #uncheck-all-ctrl': 'uncheckAll'
    'click #check-completed-ctrl': 'checkCompleted'
    'click #check-incomplete-ctrl': 'checkIncomplete'

  checkAll: (e) ->
    @.toggleAll(e, true)

  uncheckAll: (e) ->
    @.toggleAll(e, false)

  checkCompleted: (e) ->
    $inputs = @$el.find('.completed-item')
    @.toggleSubset(e, true, $inputs)

  checkIncomplete: (e) ->
    $inputs = @$el.find('.incomplete-item')
    @.toggleSubset(e, false, $inputs)

  toggleAll: (e, isChecked) ->
    $inputs = @$el.find('.select-step')
    @.toggle(e, isChecked, $inputs)

    $masterCheckbox = @$el.find('#choose-all')
    @.toggle(e, isChecked, $masterCheckbox)

  toggleSubset: (e, isChecked, $inputs) ->
    @.uncheckAll(e)

    @.toggle(e, $inputs)

  toggle: (e, isChecked, $inputs) ->
    if (isChecked)
      @.checkItems($inputs)
    else
      @.uncheckItems($inputs)

    @.rememberChecked(e)

  checkItems: (items) ->
    $(items).addClass('checked').attr('checked', 'checked').prop('checked', true)

  uncheckItems: (items) ->
    $(items).removeClass('checked').attr('checked', false).prop('checked', false)

  # Check or uncheck all items with master checkbox
  controlAll: (e) ->
    control = e.currentTarget
    $inputs = @$el.find('.select-step')

    @.toggle(e, control.checked, $inputs)

  rememberChecked: (e) ->
    ids = []

    $('.select-step').each (index) ->
      if (@.checked)
        ids.push($(@).data('id'))

    $('#step-ids').attr('value', ids)
