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
    'click .step-menu-col .fa-cog': 'openStepMenu'
    'click #project-step-menu a[data-action=edit]': 'editStep'

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
    @stepModal.new()

  editStep: (e) ->
    e.preventDefault()
    @stepModal.edit(@$(e.currentTarget).closest('[data-id]').data('id'))

  openGroupMenu: (e) ->
    @openMenu(e, 'group')

  openStepMenu: (e) ->
    @openMenu(e, 'step')

  openMenu: (e, which) ->
    link = e.currentTarget
    menu = $(link).closest('.timeline-table').find("#project-#{which}-menu")
    $(link).after(menu)
