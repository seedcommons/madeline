$ ->
  $(".batch-actions .action").click (e) ->
    item = this
    $link = $(item).find("a")
    method_key = $link.attr("data-method-key")

    $form = $(this).closest("form")
    $form.attr("data-method", method_key)

    form_data = $form.serialize()
    console.log(form_data)
