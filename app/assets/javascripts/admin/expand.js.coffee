$ ->
  $('.more').click () ->
    $(this).closest(".expandable").addClass("expanded")

  $('.less').click () ->
    $(this).closest(".expandable").removeClass("expanded")
