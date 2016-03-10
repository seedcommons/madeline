$ ->
  $(".batch-actions .batch-action").on 'confirm:complete', (e) ->
    adjust_form(e.currentTarget)

  $("#adjust-dates-confirm").click (e) ->
    $("#adjust-dates-modal").modal('hide')
    adjust_form(e.currentTarget)

  $("#adjust-dates").on "shown.bs.modal", () ->
    $("#adjust-dates-modal").focus()

  adjust_form = (item) ->
    method_key = $(item).attr("data-method-key")
    action_key = $(item).attr("data-action-key")

    $form = $(item).closest("form")

    $form.find("#set-method").attr("value", method_key)
    $form.attr("action", action_key)

    $form.submit()
