class MS.Views.DashboardProjectsView extends Backbone.View
  el: '.projects-grid'

  initialize: ->
    @$all_projects = @$('.project-status').closest('tr')
    @$active_projects = @$('.project-status.active').closest('tr')
    @$completed_projects = @$('.project-status.completed').closest('tr')

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
    @$all_projects.show()

  showActiveProjects: ->
    @$active_projects.show()
    @$completed_projects.hide()

  showCompletedProjects: ->
    @$completed_projects.show()
    @$active_projects.hide()
