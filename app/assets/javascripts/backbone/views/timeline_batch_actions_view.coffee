class MS.Views.TimelineBatchActionsView extends Backbone.View

  el: 'body'

  events: (params) ->
    "confirm:complete .batch-actions .batch-action": 'adjust_form'
    "click #adjust-dates-confirm": 'hide_adjust_dates_modal'
    "shown.bs.modal #adjust-dates": 'show_adjust_dates_modal'
  
  adjust_form: (e) ->
    item = e.currentTarget
    method_key = $(item).attr("data-method-key")
    action_key = $(item).attr("data-action-key")

    $form = $(item).closest("form")

    $form.find("#set-method").attr("value", method_key)
    $form.attr("action", action_key)

    $form.submit()

  hide_adjust_dates_modal: (e) ->
    $("#adjust-dates-modal").modal('hide')
    this.adjust_form(e)

  show_adjust_dates_modal: (e) ->
    $("#adjust-dates-modal").focus()
