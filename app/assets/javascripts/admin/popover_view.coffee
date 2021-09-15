class MS.Views.PopoverView extends Backbone.View
  el: 'body'

  initialize: (params) ->
    @initializePopovers()
    @prepTooltips()

  events: ->
    'mouseenter .ms-tooltip.ms-popover': 'showTooltip'
    'mouseleave .ms-tooltip.ms-popover': 'hideTooltip'

  initializePopovers: ->
    # Popovers are used for documentation.
    # By default, when clicked, the popover appears.
    # Popovers are a Bootstrap component.
    $('.ms-popover').popover()

  prepTooltips: ->
    # Tooltips share developer-generated information.
    @$('.ms-tooltip').each (index, tip) ->
      message = $(tip).closest('[data-message]').data('message')
      placement = $(tip).closest('[data-placement]').data('placement') || 'right'
      $(tip).addClass('ms-popover').popover
        content: message
        html: true
        placement: placement
        toggle: 'popover'
        trigger: 'manual'

  showTooltip: (e) ->
    $curPopover = $(e.currentTarget)
    $curPopover.popover('show')

  hideTooltip: (e) ->
    $curPopover = $(e.currentTarget)
    $curPopover.popover('hide')
