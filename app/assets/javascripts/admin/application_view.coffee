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
    'mouseenter .ms-tooltip.ms-popover': 'showPopover'
    'mouseleave .ms-tooltip.ms-popover': 'hidePopover'
    'shown.bs.modal .modal': 'preventMultipleModalBackdrops'

  hidePopover: (e) ->
    $curPopover = $(e.currentTarget)
    $curPopover.popover('hide')

  initializeAutocompleteSelects: ->
    $('.autocomplete-select').select2()

  initializePopovers: ->
    # Popovers are used for admin-generated documentation. When clicked, the popover appears.
    # Popovers are a Bootstrap component.
    $('.ms-popover').popover()

  prepTooltips: ->
    # Tooltips share developer-generated information and are displayed on hover.
    # Tooltips are a Bootstrap component.
    @$('.ms-tooltip').each (index, tip) =>
      message = $(tip).closest('[data-message]').data('message')
      $(tip).addClass('ms-popover').popover
        content: message
        html: true
        placement: 'right'
        toggle: 'popover'
        trigger: 'manual'

  preventMultipleModalBackdrops: ->
    if (@$(".modal-backdrop").length > 1)
      @$(".modal-backdrop").not(':first').remove()

  showPopover: (e) ->
    $curPopover = $(e.currentTarget)
    $curPopover.popover('show')

  toggleExpanded: (e) ->
    @$(e.currentTarget).closest(".expandable").toggleClass("expanded")
