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
    $link = @$(e.currentTarget)
    targetName = $link.data('expands')
    target = @$("[data-expandable='#{targetName}']")

    # Insert html in data-content if present
    if $link.data('content') && !$link.data('inserted')
      target.html($link.data('content'))
      $link.data('inserted', true)

    # Show/hide target and links
    target.show('fast')
    @$("[data-hides='#{targetName}']").show()
    @$(e.currentTarget).hide()

    # If expand/hide all exists in same menu, show expand all link
    $link.siblings('[data-expand-all]').show()

  hide: (e) ->
    e.preventDefault()
    $link = @$(e.currentTarget)
    targetName = $link.data('hides')

    # Hide content
    @$("[data-expandable='#{targetName}']").hide('fast')

    # Hide self and show opposite link control
    @$(e.currentTarget).hide()
    @$("[data-expands='#{targetName}']").show()

    # If expand/hide all actions exist in same menu, hide the links
    $link.siblings('[data-expand-all]').hide()
    $link.siblings('[data-hide-all]').hide()

  expandAll: (e) ->
    e.preventDefault()
    selector = @$(e.currentTarget).data('expand-all')
    @$("[data-expand-all='#{selector}']").hide()
    @$("[data-hide-all='#{selector}']").show()

    $container = @$(selector)
    $container.find('[data-expandable]').show('fast')
    $container.find('[data-hides]').show()
    $container.find('[data-expands]').hide()

  hideAll: (e) ->
    e.preventDefault()
    selector = @$(e.currentTarget).data('hide-all')
    @$("[data-hide-all='#{selector}']").hide()
    @$("[data-expand-all='#{selector}']").show()

    $container = @$(selector)
    $container.find('[data-expandable]').hide('fast')
    $container.find('[data-hides]').hide()
    $container.find('[data-expands]').show()
