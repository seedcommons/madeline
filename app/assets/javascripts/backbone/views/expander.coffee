# Looks for any links/buttons with data-expands, shows all elements matching data-expandable on click
class MS.Views.Expander extends Backbone.View
  el: 'body'

  events:
    'click [data-expands]': 'expand'

  expand: (e) ->
    console.log("HERE", e.target)
    e.preventDefault()
    target = @$(e.currentTarget).data('expands')
    console.log("[data-expandable='#{target}']")
    @$("[data-expandable='#{target}']").show()
    @$(e.currentTarget).hide()
