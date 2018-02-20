class MS.Views.DashboardView extends Backbone.View
  el: '.admin-dashboard .content'

  initialize: ->
    @prepTooltips()

  # Prepare tooltips on all projects shown for all users in the dashboard
  prepTooltips: ->
    @$('.ms-tooltip').each (index, tip) ->
      message = $(tip).closest('.health-message').find('.message').html()

      $(tip).addClass('ms-popover').popover
        content: message
        html: true
        placement: 'left'
        toggle: 'popover'
        trigger: 'manual'
