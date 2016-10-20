# Controls the timeline modal (no more than one per page).
class MS.Views.TimelineTableView extends Backbone.View

  el: 'section.timeline-table'

  initialize: (options) ->
    @loanId = options.loanId
    @modal = new MS.Views.ProjectGroupModalView(loanId: @loanId, success: @refresh.bind(@))

  events:
    'click .timeline-action.new': 'newGroup'
    'click #project-group-menu [data-action="edit"]': 'editGroup'
    'click #project-group-menu [data-action="add-child-group"]': 'newChildGroup'
    'click .project-group .fa-cog': 'openGroupMenu'

  refresh: ->
    MS.loadingIndicator.show()
    @$('.timeline-table').empty()
    $.get "/admin/loans/#{@loanId}/timeline", (html) =>
      MS.loadingIndicator.hide()
      @$el.html(html)

  newGroup: (e) ->
    e.preventDefault()
    @modal.new()

  newChildGroup: (e) ->
    e.preventDefault()
    @modal.new(@parentId(e))

  editGroup: (e) ->
    e.preventDefault()
    @modal.edit(@parentId(e))

  openGroupMenu: (e) ->
    @$(e.currentTarget).after(@$('#project-group-menu'))

  parentId: (e) ->
    @$(e.target).closest(".project-group").data("action-key")
