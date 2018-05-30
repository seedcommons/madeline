# For public loans
class MS.Views.LoanView extends Backbone.View

  el: '.loans'

  initialize: ->
    @initializeTabs()
    @initializeCarousel()

  events: ->
    'click .nav-tabs .nav-item a': 'styleTabs'

  initializeTabs: ->
    # Loan tabs use jQuery UI Tab functionality
    @$el.find('#tabs').tabs({
      active: 0
    });

  initializeCarousel: ->
    # Initiate slideshow
    @$el.find(".carousel-inner .carousel-item").first().addClass('active')
    @$el.find(".carousel").carousel()

  styleTabs: () ->
    # Loan tabs use jQuery UI tab functionality and Bootstrap styling.
    # Allow the selected tab indicator to persist when focus changes to other elements.
    # The 'active' class is a styling class for tabs for Bootstrap.
    tabList = @$(".nav-tabs")
    tabList.find(".nav-link").removeClass('active')
    tabList.find(".nav-item[aria-selected='true'] .nav-link").addClass('active')
