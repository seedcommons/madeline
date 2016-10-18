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
    'click .project-group .disabled a': 'disableDeleteLink'
    'confirm:complete': 'deleteConfirm'

  refresh: ->
    MS.loadingIndicator.show()
    @$('.timeline-table').empty()
    $.get "/admin/loans/#{@loanId}/timeline", (html) =>
      MS.loadingIndicator.hide()
      @$el.html(html)

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
    $delete_button = $('#project-group-menu a[data-action="delete"]').closest('li')

    has_children = $(e.currentTarget).closest('.project-group').hasClass('with-children')
    if (has_children)
      $delete_button.addClass('disabled')
    else
      $delete_button.removeClass('disabled')

    $(e.currentTarget).after($menu)

  deleteConfirm: (e, response) ->
    e.preventDefault()

    id = $(e.target).closest('.project-group').data('id')

    MS.loadingIndicator.show()
    $.post  "/admin/project_groups/#{id}", {'_method': 'DELETE'}, (html) =>
      MS.loadingIndicator.hide()
      @refresh()

  # Disable the link and prevent confirm dialog
  # when li is set to disabled.
  disableDeleteLink: (e) ->
    e.stopPropagation()
