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

  showActiveProjects: ->
    console.log("active projects")

  showCompletedProjects: ->
    console.log("completed projects")
