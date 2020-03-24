# This view is for general functions for the entire app, including admin and frontend
# Should be used sparingly. Prefer separate views (perhaps instantiated from in here)
# for cohesive pieces of functionality.
class MS.Views.ApplicationView extends Backbone.View

  el: 'body'

  initialize: (params) ->
    new MS.Views.ErrorHandler({locale: params.locale})
    new MS.Views.Expander()
    MS.alert = (html) ->
      $alert = $(html).hide()
      $alert.appendTo($('.alerts')).show('fast')
    MS.dateFormats = params.dateFormats
    $.fn.datepicker.defaults.language = params.locale
    @initializeAutocompleteSelects()
    @initializePopovers()
    @prepTooltips()

  events: ->
    'click .more': 'toggleExpanded'
    'click .less': 'toggleExpanded'
    'mouseenter .ms-tooltip.ms-popover': 'showTooltip'
    'mouseleave .ms-tooltip.ms-popover': 'hideTooltip'
    'shown.bs.modal .modal': 'preventMultipleModalBackdrops'

  hideTooltip: (e) ->
    $curPopover = $(e.currentTarget)
    $curPopover.popover('hide')

  initializeAutocompleteSelects: ->
    $('.autocomplete-select').select2()

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

  preventMultipleModalBackdrops: ->
    if (@$(".modal-backdrop").length > 1)
      @$(".modal-backdrop").not(':first').remove()

  showTooltip: (e) ->
    $curPopover = $(e.currentTarget)
    $curPopover.popover('show')

  toggleExpanded: (e) ->
    @$(e.currentTarget).closest(".expandable").toggleClass("expanded")
