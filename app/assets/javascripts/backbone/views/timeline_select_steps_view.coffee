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
    $inputs = @$el.find('.select-step')
    @.checkItems($inputs)

    $masterCheckbox = $('#choose-all')
    @.checkItems($masterCheckbox)

    @.rememberChecked(e)

  uncheckAll: (e) ->
    $inputs = @$el.find('.select-step')
    @.uncheckItems($inputs)

    $masterCheckbox = $('#choose-all')
    @.uncheckItems($masterCheckbox)

    @.rememberChecked(e)

  checkCompleted: (e) ->
    @.uncheckAll(e)

    $inputs = @$el.find('.completed-item')
    @.checkItems($inputs)

    @.rememberChecked(e)

  checkIncomplete: (e) ->
    @.uncheckAll(e)

    $inputs = @$el.find('.incomplete-item')
    @.checkItems($inputs)

    @.rememberChecked(e)

  checkItems: (items) ->
    $(items).addClass('checked').attr('checked', 'checked').prop('checked', true)

  uncheckItems: (items) ->
    $(items).removeClass('checked').attr('checked', false).prop('checked', false)

  # Check or uncheck all items with master checkbox
  controlAll: (e) ->
    control = e.currentTarget
    $inputs = @$el.find('.select-step')

    if (control.checked)
      @.checkItems($inputs)
    else
      @.uncheckItems($inputs)

    @.rememberChecked(e)

  rememberChecked: (e) ->
    ids = []

    $('.select-step').each (index) ->
      if (@.checked)
        ids.push($(@).data('id'))

    $('#step-ids').attr('value', ids)
