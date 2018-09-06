class MS.Views.DashboardView extends Backbone.View
  el: '.admin-dashboard .content'

  events:
    'click .project-step-item': 'stepClick'

  initialize: (params) ->
    @stepModal = params.stepModal
    @prepTooltips()

  # Prepare tooltips on all projects shown for all users in the dashboard
  prepTooltips: ->
    @$('.ms-tooltip').each (index, tip) ->
      message = $(tip).closest('.tooltip-message').find('.message').html()

      $(tip).addClass('ms-popover').popover
        content: message
        html: true
        placement: 'left'
        toggle: 'popover'
        trigger: 'manual'

  stepClick: (e) ->
    if !(@$(e.target).is('a'))
      @stepModal.show(@$(e.target).closest('tr').data('id'))
