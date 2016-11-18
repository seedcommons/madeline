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
    @toggleSubset(true, @$('.select-step.completed'))

  checkIncomplete: ->
    @toggleSubset(true, @$('.select-step:not(.completed)'))

  toggleAll: (isChecked) ->
    @toggle(isChecked, @$('.select-step'))
    @toggle(isChecked, @$('#choose-all'))

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

    @toggle(control.checked, @$('.select-step'))

  rememberChecked: ->
    ids = []

    @$('.select-step').each (index) ->
      if @checked
        ids.push($(@).data('id'))

    @$('.step-ids').attr('value', ids)
