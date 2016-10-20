# Controls the timeline modal (no more than one per page).
class MS.Views.TimelineTableView extends Backbone.View

  el: 'section.timeline-table'

  initialize: (options) ->
    new MS.Views.AutoLoadingIndicatorView()
    @loanId = options.loanId
    @modal = new MS.Views.ProjectGroupModalView(loanId: @loanId, success: @refresh.bind(@))

  events:
    'click .timeline-action.new': 'newGroup'
    'click #project-group-menu [data-action="edit"]': 'editGroup'
    'click #project-group-menu [data-action="add-child-group"]': 'newChildGroup'
    'click .project-group .fa-cog': 'openGroupMenu'
    'click .project-group .disabled a': 'disableDeleteLink'
    'confirm:complete': 'deleteConfirm'

  refresh: ->
    @$('.timeline-table').empty()
    $.get("/admin/loans/#{@loanId}/timeline")
    .done (response) =>
      @$el.html(response)

  newGroup: (e) ->
    e.preventDefault()
    @modal.new()

  newChildGroup: (e) ->
    e.preventDefault()
    @modal.new(@parentId(e))

  editGroup: (e) ->
    e.preventDefault()
    @modal.edit(@parentId(e))

  deleteConfirm: (e, response) ->
    e.preventDefault()

    $.post("/admin/project_groups/#{@parentId(e)}", {'_method': 'DELETE'})
    .done () =>
      @refresh()
    .fail (response) =>
      MS.alert(response.responseText)

  openGroupMenu: (e) ->
    $delete_link = @$('#project-group-menu a[data-action="delete"]').closest('li')

    if @$(e.currentTarget).closest('.project-group').hasClass('with-children')
      $delete_link.addClass('disabled')
    else
      $delete_link.removeClass('disabled')

    @$(e.currentTarget).after(@$('#project-group-menu'))

  parentId: (e) ->
    @$(e.target).closest(".project-group").data("id")

  # Disable the link and prevent confirm dialog
  # when li is set to disabled.
  disableDeleteLink: (e) ->
    e.stopPropagation()
