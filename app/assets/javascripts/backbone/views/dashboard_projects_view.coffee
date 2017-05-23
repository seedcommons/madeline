class MS.Views.DashboardProjectsView extends Backbone.View
  el: '.projects-grid'

  initialize: ->
    @$allProjects = @$('.project-status').closest('tr')
    @$activeProjects = @$('.project-status.active').closest('tr')
    @$completedProjects = @$('.project-status.completed').closest('tr')

    @prepTooltips()

  events:
    'change #completion_status': 'filterProjects'

  filterProjects: (e) ->
    e.preventDefault()
    $select = $(e.currentTarget)
    filter = $select.val()

    if filter == 'all'
      @showAllProjects()
    else if filter == 'active'
      @showActiveProjects()
    else
      @showCompletedProjects()

  showAllProjects: ->
    @$allProjects.show()

  showActiveProjects: ->
    @$activeProjects.show()
    @$completedProjects.hide()

  showCompletedProjects: ->
    @$completedProjects.show()
    @$activeProjects.hide()

  prepTooltips: ->
    @$('.ms-tooltip').each (index, tip) ->
      message = $(tip).closest('.health-message').find('.message').html()

      $(tip).addClass('ms-popover').popover
        content: message
        html: true
        placement: 'left'
        toggle: 'popover'
        trigger: 'manual'
