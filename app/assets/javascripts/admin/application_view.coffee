# This view is for general functions for the entire app, including admin and frontend
# Should be used sparingly. Prefer separate views (perhaps instantiated from in here)
# for cohesive pieces of functionality.
class MS.Views.ApplicationView extends Backbone.View

  el: 'body'

  initialize: (params) ->
    new MS.Views.ErrorHandler()
    new MS.Views.Expander()
    MS.alert = (html) ->
      $alert = $(html).hide()
      $alert.appendTo($('.alerts')).show('fast')
    MS.dateFormats = params.dateFormats
    $.fn.datepicker.defaults.language = params.locale

  events: ->
    'click .more': 'toggleExpanded'
    'click .less': 'toggleExpanded'
    'click .ms-popover.inactive-popover': 'showPopover'
    'click .ms-popover.active-popover': 'hidePopover'
    'mouseenter .ms-tooltip.ms-popover': 'showTooltip'
    'mouseleave .ms-tooltip.ms-popover': 'hideTooltip'
    'shown.bs.modal .modal': 'preventMultipleModalBackdrops'

  toggleExpanded: (e) ->
    @$(e.currentTarget).closest(".expandable").toggleClass("expanded")

  showPopover: (e) ->
    console.log("Showing popover")
    curPopover = $(e.currentTarget)
    curPopover.popover('show')
    curPopover.removeClass("inactive-popover")
    curPopover.addClass("active-popover")
    # self = this
    # console.log("Popover initialized")
    # hide = (e) ->
    #   console.log("Entering hide")
    #   unless self.$(e.target).is('.ms-popover')
    #     self.$('.ms-popover').popover('hide')
    #     self.$el.off 'click', hide # Unregister for performance reasons
    #     console.log("Maybe I'm not hiding")
    # @$el.on 'click', hide

  hidePopover: (e) ->
    console.log("Hiding popover")
    curPopover = $(e.currentTarget)
    curPopover.popover('hide')
    curPopover.removeClass("active-popover")
    curPopover.addClass("inactive-popover")
    # self = this
    # console.log("Entering hide")
    # unless self.$(e.target).is('.ms-popover')
    #   self.$('.ms-popover').popover('hide')
    #   self.$el.off 'click', hide # Unregister for performance reasons
    #   console.log("Maybe I'm not hiding")

  showTooltip: (e) ->
    $curPopover = $(e.currentTarget)
    $curPopover.popover('show')

  hideTooltip: (e) ->
    $curPopover = $(e.currentTarget)
    $curPopover.popover('hide')

  preventMultipleModalBackdrops: ->
    if (@$(".modal-backdrop").length > 1)
      @$(".modal-backdrop").not(':first').remove()
