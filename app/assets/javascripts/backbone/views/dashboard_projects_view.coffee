class MS.Views.DashboardProjectsView extends Backbone.View
  el: '.projects-grid'

  events:
    'change #completion_status': 'filterProjects'

  filterProjects: (e) ->
    e.preventDefault()
    $select = $(e.currentTarget)
    console.log($select.val())
