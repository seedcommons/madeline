class MS.Views.PageView extends Backbone.View

  el: ".select_division_form"

  events: (params) ->
    'change select': 'selectDivision'

  selectDivision: (e) ->
    $item = $(e.currentTarget)
    $("input[name=redisplay_url]").val(window.location)
    $form = $item.closest('form')
    $form.submit()
