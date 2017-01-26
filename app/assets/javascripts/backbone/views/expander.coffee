# Expands and hides content.
# Can control one content area or multiple content areas at once.
class MS.Views.Expander extends Backbone.View
  el: 'body'

  events:
    'click [data-expands]': 'expand'
    'click [data-hides]': 'hide'
    'click [data-expand-all]': 'expandAll'
    'click [data-hide-all]': 'hideAll'

  # Expands one content element.
  # Responds to a link/button/control that has an attribute of [data-expands="key"].
  # Looks for elements with [data-expandable="key"] and expands their content.
  # Optionally inserts content in [data-content] on first expansion.
  # Works with the hide function as its opposite.
  expand: (e) ->
    e.preventDefault()
    $link = @$(e.currentTarget)
    targetName = $link.data('expands')
    target = @$("[data-expandable='#{targetName}']")

    # Insert html in [data-content] if present.
    if $link.data('content') && !$link.data('inserted')
      target.html($link.data('content'))
      $link.data('inserted', true)

    # Show content.
    target.show('fast')

    # Hide the 'expand' control and show the 'hide' control.
    @$("[data-hides='#{targetName}']").show()
    @$(e.currentTarget).hide()

    # If [data-expand-all] and [data-hide-all] exist in same menu, show [data-expand-all] control.
    $link.siblings('[data-expand-all]').show()

  # Hides one content element whose identifier is specified in the attribute [data-hides="key"].
  # Looks for elements with [data-expandable="key"] and hides their content.
  # Works with the expand function as its opposite.
  hide: (e) ->
    e.preventDefault()
    $link = @$(e.currentTarget)
    targetName = $link.data('hides')

    # Hide content.
    @$("[data-expandable='#{targetName}']").hide('fast')

    # Hide the 'hide' control and show the 'expand' control.
    @$(e.currentTarget).hide()
    @$("[data-expands='#{targetName}']").show()

    # If [data-expand-all] and [data-hide-all] exist in same menu, hide these controls.
    $link.siblings('[data-expand-all]').hide()
    $link.siblings('[data-hide-all]').hide()

  # Expands all expandable content elements within a container.
  # Selector for container is specified as [data-expand-all="selector"] on the expandAll control.
  # Looks for content matching the specificed selector.
  # All items that have [data-expandable] within the container are expanded.
  # Works with the hideAll function as its opposite.
  expandAll: (e) ->
    e.preventDefault()
    selector = @$(e.currentTarget).data('expand-all')
    @$("[data-expand-all='#{selector}']").hide()
    @$("[data-hide-all='#{selector}']").show()

    $container = @$(selector)
    $container.find('[data-expandable]').show('fast')
    $container.find('[data-hides]').show()
    $container.find('[data-expands]').hide()

  # Hides all expandable content within a container.
  # Selector for container is specified as [data-hides-all="selector"] on the hideAll control.
  # Looks for elements within a container that have [data-expandable]. Hides this content.
  # Works with the expandAll function as its opposite.
  hideAll: (e) ->
    e.preventDefault()
    selector = @$(e.currentTarget).data('hide-all')
    @$("[data-hide-all='#{selector}']").hide()
    @$("[data-expand-all='#{selector}']").show()

    $container = @$(selector)
    $container.find('[data-expandable]').hide('fast')
    $container.find('[data-hides]').hide()
    $container.find('[data-expands]').show()
