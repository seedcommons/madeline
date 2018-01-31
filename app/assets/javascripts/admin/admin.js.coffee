$ ->
  # Prevent modals from adding more than one backdrop
  $(".modal").on "shown.bs.modal", ->
    if ($(".modal-backdrop").length > 1)
      $(".modal-backdrop").not(':first').remove()
