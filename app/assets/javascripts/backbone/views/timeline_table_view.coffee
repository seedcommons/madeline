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
    @modal.show()

  newChildGroup: (e) ->
    e.preventDefault()

    id = $(e.target).closest('.project-group').data('id')
    @modal.show(id)

  editGroup: (e) ->
    e.preventDefault()

    id = $(e.target).closest('.project-group').data('id')
    @modal.edit(id)

  openGroupMenu: (e) ->
    $menu = $(e.currentTarget).closest('.timeline-table').find('#project-group-menu')
    $delete_link = $('#project-group-menu a[data-action="delete"]').closest('li')

    if $(e.currentTarget).closest('.project-group').hasClass('with-children')
      $delete_link.addClass('disabled')
    else
      $delete_link.removeClass('disabled')

    $(e.currentTarget).after($menu)

  deleteConfirm: (e, response) ->
    e.preventDefault()

    id = $(e.target).closest('.project-group').data('id')

    $.post("/admin/project_groups/#{id}", {'_method': 'DELETE'})
    .done () =>
      @refresh()
    .fail (response) =>
      MS.alert(response.responseText)

  # Disable the link and prevent confirm dialog
  # when li is set to disabled.
  disableDeleteLink: (e) ->
    e.stopPropagation()
