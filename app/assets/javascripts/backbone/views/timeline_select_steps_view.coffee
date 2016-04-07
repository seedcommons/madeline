class MS.Views.TimelineSelectStepsView extends Backbone.View

  el: 'body'

  events: (params) ->
    'change .select-step': 'remember_checked'
    'click #choose-all': 'control_all'
    'click #check-all-ctrl': 'check_all'
    'click #uncheck-all-ctrl': 'uncheck_all'
    'click #check-completed-ctrl': 'check_completed'
    'click #check-incomplete-ctrl': 'check_incomplete'
 
  check_all: (e) ->
    control = e.currentTarget
    $inputs = $(control).closest(".timeline").find('.select-step')
    this.check_items($inputs)

    $master_checkbox = $(control).closest(".btn-group").find("#choose-all")
    this.check_items($master_checkbox)

    this.remember_checked(e)

  uncheck_all: (e) ->
    control = e.currentTarget
    $inputs = $(control).closest(".timeline").find('.select-step')
    this.uncheck_items($inputs)

    $master_checkbox = $(control).closest(".btn-group").find("#choose-all")
    this.uncheck_items($master_checkbox)

    this.remember_checked(e)

  check_completed: (e) ->
    this.uncheck_all(e)

    control = e.currentTarget
    $inputs = $(control).closest(".timeline").find('.completed-item')
    this.check_items($inputs)

    this.remember_checked(e)

  check_incomplete: (e) ->
    this.uncheck_all(e)

    control = e.currentTarget
    $inputs = $(control).closest(".timeline").find('.incomplete-item')
    this.check_items($inputs)

    this.remember_checked(e)

  check_items: (items) ->
    $(items).addClass('checked').attr('checked', "checked").prop("checked", true)

  uncheck_items: (items) ->
    $(items).removeClass('checked').attr('checked', false).prop("checked", false)

  # Check or uncheck all items with master checkbox
  control_all: (e) ->
    control = e.currentTarget
    $inputs = $(control).closest(".timeline").find('.select-step')

    if (control.checked == true)
      this.check_items($inputs)
    else
      this.uncheck_items($inputs)

    this.remember_checked(e)

  remember_checked: (e) ->
    ids = [];

    $('.select-step').each (index) ->
      if (this.checked == true)
        ids.push($(this).data('id'))

    $("#step-ids").attr("value", ids)
