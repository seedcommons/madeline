# Looks for any links/buttons with data-expands, shows all elements matching data-expandable on click.
# Optionally inserts content in data-content on first expansion.
class MS.Views.Expander extends Backbone.View
  el: 'body'

  events:
    'click [data-expands]': 'expand'
    'click [data-hides]': 'hide'
    'click [data-expand-all]': 'expandAll'
    'click [data-hide-all]': 'hideAll'

  expand: (e) ->
    e.preventDefault()
    link = @$(e.currentTarget)
    targetName = link.data('expands')
    target = @$("[data-expandable='#{targetName}']")

    # Insert html in data-content if present
    if link.data('content') && !link.data('inserted')
      target.html(link.data('content'))
      link.data('inserted', true)

    # Show/hide target and links
    target.show('fast')
    @$("[data-hides='#{targetName}']").show()
    @$(e.currentTarget).hide()

  hide: (e) ->
    e.preventDefault()
    targetName = @$(e.currentTarget).data('hides')
    @$("[data-expandable='#{targetName}']").hide('fast')
    @$("[data-expands='#{targetName}']").show()
    @$(e.currentTarget).hide()

  expandAll: (e) ->
    e.preventDefault()
    selector = @$(e.currentTarget).data('expand-all')
    $container = @$(selector)
    $container.find('[data-expandable]').show('fast')
    $container.find('[data-hides]').show('fast')
    $container.find('[data-expands]').hide('fast')

  hideAll: (e) ->
    e.preventDefault()
    targetName = @$(e.currentTarget).data('hide-all')
    console.log(targetName)
