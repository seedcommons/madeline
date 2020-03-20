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
    @prepTooltips()
    @initializePopovers()
    @initializeAutocompleteSelects()

  events: ->
    'click .more': 'toggleExpanded'
    'click .less': 'toggleExpanded'
    'mouseenter .ms-tooltip.ms-popover': 'showTooltip'
    'mouseleave .ms-tooltip.ms-popover': 'hideTooltip'
    'shown.bs.modal .modal': 'preventMultipleModalBackdrops'

  toggleExpanded: (e) ->
    @$(e.currentTarget).closest(".expandable").toggleClass("expanded")

  initializePopovers: ->
    # Popovers are a Bootstrap component.
    # Bootstrap handles showing and hiding popovers.
    $('.ms-popover').popover()

  showTooltip: (e) ->
    $curPopover = $(e.currentTarget)
    $curPopover.popover('show')

  hideTooltip: (e) ->
    $curPopover = $(e.currentTarget)
    $curPopover.popover('hide')

  preventMultipleModalBackdrops: ->
    if (@$(".modal-backdrop").length > 1)
      @$(".modal-backdrop").not(':first').remove()

  initializeAutocompleteSelects: ->
    $('.autocomplete-select').select2()

  prepTooltips: ->
    @$('.ms-tooltip').each (index, tip) =>
      message = $(tip).closest('[data-message]').data('message')
      $(tip).addClass('ms-popover').popover
        content: message
        html: true
        placement: 'right'
        toggle: 'popover'
        trigger: 'manual'
