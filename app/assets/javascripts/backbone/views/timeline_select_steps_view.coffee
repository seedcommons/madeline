class MS.Views.TimelineSelectStepsView extends Backbone.View

  events: (params) ->
    'change .select-step': 'rememberChecked'
    'click #choose-all': 'controlAll'
    'click #check-all-ctrl': 'checkAll'
    'click #uncheck-all-ctrl': 'uncheckAll'
    'click #check-completed-ctrl': 'checkCompleted'
    'click #check-incomplete-ctrl': 'checkIncomplete'

  checkAll: ->
    @toggleAll(true)

  uncheckAll: ->
    @toggleAll(false)

  checkCompleted: ->
    $inputs = @$('.select-step.completed')
    @toggleSubset(true, $inputs)

  checkIncomplete: ->
    $inputs = @$('.select-step:not(.completed)')
    @toggleSubset(true, $inputs)

  toggleAll: (isChecked) ->
    $inputs = @$('.select-step')
    @toggle(isChecked, $inputs)

    $masterCheckbox = @$('#choose-all')
    @toggle(isChecked, $masterCheckbox)

  toggleSubset: (isChecked, $inputs) ->
    @uncheckAll()

    @toggle(isChecked, $inputs)

  toggle: (isChecked, $inputs) ->
    if isChecked
      @checkItems($inputs)
    else
      @uncheckItems($inputs)

    @rememberChecked()

  checkItems: (items) ->
    $(items).addClass('checked').attr('checked', 'checked').prop('checked', true)

  uncheckItems: (items) ->
    $(items).removeClass('checked').attr('checked', false).prop('checked', false)

  # Check or uncheck all items with master checkbox
  controlAll: (e) ->
    control = e.currentTarget
    $inputs = @$('.select-step')

    @toggle(control.checked, $inputs)

  rememberChecked: ->
    ids = []

    $('.select-step').each (index) ->
      if @checked
        ids.push($(@).data('id'))

    $('#step-ids').attr('value', ids)
