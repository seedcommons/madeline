# Controls the timeline modal (no more than one per page).
class MS.Views.TimelineTableView extends Backbone.View

  el: 'section.timeline-table'

  initialize: (options) ->
    @loanId = options.loanId
    @groupModal = new MS.Views.ProjectGroupModalView(loanId: @loanId, success: @refresh.bind(@))
    @stepModal = new MS.Views.ProjectStepModalView(loanId: @loanId, success: @refresh.bind(@))

  events:
    'click .timeline-action[data-action="new-group"]': 'newGroup'
    'click .timeline-action[data-action="new-step"]': 'newStep'
    'click .project-group .fa-cog': 'openGroupMenu'
    'click [data-menu="step"] .fa-cog': 'openStepMenu'
    'click #project-step-menu [data-action="delete"]': 'deleteStep'

  refresh: ->
    MS.loadingIndicator.show()
    @$('.timeline-table').empty()
    $.get "/admin/loans/#{@loanId}/timeline", (html) =>
      MS.loadingIndicator.hide()
      @$el.html(html)

  newGroup: (e) ->
    e.preventDefault()
    @groupModal.show()

  newStep: (e) ->
    e.preventDefault()
    @stepModal.show()

  openGroupMenu: (e) ->
    button = e.currentTarget
    menu = $(button).closest('.timeline-table').find('#project-group-menu')
    $(button).after(menu)

  openStepMenu: (e) ->
    button = e.currentTarget
    menu = $(button).closest('.timeline-table').find('#project-step-menu')
    $(button).after(menu)

  deleteStep: (e) ->
    item = e.currentTarget
    stepId = $(item).closest('.dropdown').attr('data-step-id')
    $.ajax(type: "DELETE", url: "/admin/project_steps/#{stepId}")
    .done =>
    .fail (response) ->
      MS.alert(response.responseText)
