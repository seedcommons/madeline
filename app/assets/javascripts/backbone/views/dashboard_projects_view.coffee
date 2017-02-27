class MS.Views.DashboardProjectsView extends Backbone.View
  el: '.projects-grid'

  events:
    'change #completion_status': 'filterProjects'

  filterProjects: (e) ->
    e.preventDefault()
    $select = $(e.currentTarget)
    filter = $select.val()
    console.log(filter)

    if filter == 'all'
      @showAllProjects()
    else if filter == 'active'
      @showActiveProjects()
    else
      @showCompletedProjects()

  showAllProjects: ->
    console.log("all projects")
    console.log(@$('.project-status').closest('tr'))
    @$all_projects = @$('.project-status').closest('tr')
    @$all_projects.show()

  showActiveProjects: ->
    console.log("active projects")
    console.log(@$('.project-status.active').closest('tr'))
    @$active_projects = @$('.project-status.active').closest('tr')
    @$completed_projects = @$('.project-status.completed').closest('tr')
    @$active_projects.show()
    @$completed_projects.hide()

  showCompletedProjects: ->
    console.log("completed projects")
    console.log(@$('.project-status.completed').closest('tr'))
    @$active_projects = @$('.project-status.active').closest('tr')
    @$completed_projects = @$('.project-status.completed').closest('tr')
    @$completed_projects.show()
    @$active_projects.hide()
