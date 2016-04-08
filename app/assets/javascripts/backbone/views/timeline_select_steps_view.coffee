class MS.Views.TimelineSelectStepsView extends Backbone.View

  el: 'body'

  events: (params) ->
    'change .select-step': 'rememberChecked'
    'click #choose-all': 'controlAll'
    'click #check-all-ctrl': 'checkAll'
    'click #uncheck-all-ctrl': 'uncheckAll'
    'click #check-completed-ctrl': 'checkCompleted'
    'click #check-incomplete-ctrl': 'checkIncomplete'
 
  checkAll: (e) ->
    $control = $(e.currentTarget)
    $inputs = $control.closest('.timeline').find('.select-step')
    this.checkItems($inputs)

    $masterCheckbox = $control.closest('.btn-group').find('#choose-all')
    this.checkItems($masterCheckbox)

    this.rememberChecked(e)

  uncheckAll: (e) ->
    $control = $(e.currentTarget)
    $inputs = $control.closest('.timeline').find('.select-step')
    this.uncheckItems($inputs)

    $masterCheckbox = $control.closest('.btn-group').find('#choose-all')
    this.uncheckItems($masterCheckbox)

    this.rememberChecked(e)

  checkCompleted: (e) ->
    this.uncheckAll(e)

    $control = $(e.currentTarget)
    $inputs = $control.closest('.timeline').find('.completed-item')
    this.checkItems($inputs)

    this.rememberChecked(e)

  checkIncomplete: (e) ->
    this.uncheckAll(e)

    $control = $(e.currentTarget)
    $inputs = $control.closest('.timeline').find('.incomplete-item')
    this.checkItems($inputs)

    this.rememberChecked(e)

  checkItems: (items) ->
    $(items).addClass('checked').attr('checked', 'checked').prop('checked', true)

  uncheckItems: (items) ->
    $(items).removeClass('checked').attr('checked', false).prop('checked', false)

  # Check or uncheck all items with master checkbox
  controlAll: (e) ->
    control = e.currentTarget
    $inputs = $(control).closest('.timeline').find('.select-step')

    if (control.checked == true)
      this.checkItems($inputs)
    else
      this.uncheckItems($inputs)

    this.rememberChecked(e)

  rememberChecked: (e) ->
    ids = [];

    $('.select-step').each (index) ->
      if (this.checked == true)
        ids.push($(this).data('id'))

    $('#step-ids').attr('value', ids)
