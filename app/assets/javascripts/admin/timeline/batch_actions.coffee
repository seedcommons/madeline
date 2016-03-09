$ ->
  $(".batch-actions .action").on 'confirm:complete', (e) ->
    adjust_form(e.currentTarget)

  adjust_form = (item) ->
    $link = $(item).find("a")

    method_key = $link.attr("data-method-key")
    action_key = $link.attr("data-action-key")

    $form = $(item).closest("form")

    $form.find("#set-method").attr("value", method_key)
    $form.attr("action", action_key)

    $form.submit()
