class MS.Views.PageView extends Backbone.View

  el: 'body'

  events: (params) ->
    'change select[name="division_id"]': 'selectDivision'

  selectDivision: (e) ->
    $item = $(e.currentTarget)
    $("input[name=redisplay_url]").val(window.location)
    $form = $item.closest('form')
    $form.submit()
