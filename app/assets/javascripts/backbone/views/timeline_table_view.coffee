# Controls the timeline modal (no more than one per page).
class MS.Views.TimelineTableView extends Backbone.View

  el: 'section.timeline-table'

  initialize: (options) ->
    new MS.Views.AutoLoadingIndicatorView()
    @projectId = options.projectId
    @groupModal = new MS.Views.ProjectGroupModalView(projectId: @projectId, success: @refresh.bind(@))
    @stepModal = options.stepModal
    @duplicateStepModal = new MS.Views.DuplicateStepModalView()
    new MS.Views.TimelineSelectStepsView(el: '#timeline-table')
    new MS.Views.TimelineBatchActionsView(el: '#timeline-table')
    @timelineFilters = new MS.Views.TimelineFiltersView(el: @$('form.filters'))

  events:
    'click .project-group .fa-cog': 'openGroupMenu'
    'click .step-menu-col .fa-cog': 'openStepMenu'
    'click .timeline-action[data-action="new-group"]': 'newGroup'
    'click .timeline-action[data-action="new-step"]': 'newStep'
    'confirm:complete #project-step-menu [data-action="delete"]': 'deleteStep'
    'click #project-group-menu [data-action="add-child-group"]': 'newChildGroup'
    'click #project-group-menu [data-action="add-child-step"]': 'newChildStep'
    'click #project-group-menu [data-action="edit"]': 'editGroup'
    'confirm:complete #project-group-menu [data-action="delete"]': 'deleteGroup'
    'click #project-step-menu a[data-action=edit]': 'editStep'
    'click #project-step-menu a[data-action=add-log]': 'addLog'
    'click #project-step-menu a[data-action=add-dependent-step]': 'addDependentStep'
    'click #project-step-menu a[data-action=duplicate]': 'duplicateStep'
    'click ul.dropdown-menu li.disabled a': 'handleDisabledMenuLinkClick'
    'change form.filters': 'refresh'
    'mouseenter .step-start-date': 'showPrecedentStep'
    'mouseenter .step-end-date': 'showDependentSteps'
    'mouseleave .step-date': 'hideRelatedSteps'
    'click [data-action="view-logs"]': 'openLogList'

  refresh: ->
    MS.loadingIndicator.show()
    $.get "/admin/projects/#{@projectId}/timeline#{window.location.search}", (html) =>
      MS.loadingIndicator.hide()
      @$('.table-wrapper').html(html)
      @timelineFilters.resetFilterDropdowns()

  newGroup: (e) ->
    e.preventDefault()
    @groupModal.new()

  newChildGroup: (e) ->
    e.preventDefault()
    @groupModal.new(@parentId(e))

  newChildStep: (e) ->
    e.preventDefault()
    @stepModal.new(@$(e.currentTarget).closest('[data-project-id]').data('project-id'), @refresh.bind(@), {parentId: @parentId(e)})

  editGroup: (e) ->
    e.preventDefault()
    @groupModal.edit(@parentId(e))

  deleteGroup: (e, response) ->
    e.preventDefault()
    $.post("/admin/project_groups/#{@parentId(e)}", {'_method': 'DELETE'})
    .done => @refresh()
    .fail (response) => MS.alert(response.responseText)

  newStep: (e) ->
    e.preventDefault()
    @stepModal.new(@projectId, @refresh.bind(@))

  editStep: (e) ->
    e.preventDefault()
    @stepModal.edit(@stepIdFromEvent(e), @refresh.bind(@))

  addLog: (e) ->
    e.preventDefault()
    unless @logFormModalView
      @logFormModalView = new MS.Views.LogFormModalView(el: $("<div>").insertAfter(@$el))
    @logFormModalView.showNew(@stepIdFromEvent(e), @refresh.bind(@))

  deleteStep: (e) ->
    item = e.currentTarget
    stepId = $(item).closest('.step-menu-col').data('id')
    $.ajax(type: "DELETE", url: "/admin/project_steps/#{stepId}")
    .done =>
      @refresh()
    .fail (response) ->
      MS.alert(response.responseText)

  addDependentStep: (e) ->
    e.preventDefault()
    @stepModal.new(
      @projectId,
      @refresh.bind(@),
      precedentId: @stepIdFromEvent(e),
      parentId: @stepParentIdFromEvent(e)
    )

  parentId: (e) ->
    @$(e.target).closest(".project-group").data("id")

  openGroupMenu: (e) ->
    $deleteLink = @$('#project-group-menu a[data-action="delete"]').closest('li')

    if @$(e.currentTarget).closest('.project-group').hasClass('with-children')
      $deleteLink.addClass('disabled')
    else
      $deleteLink.removeClass('disabled')

    @openMenu(e, 'group')

  openStepMenu: (e) ->
    @openMenu(e, 'step')

  openMenu: (e, which) ->
    link = e.currentTarget
    $menu = $(link).closest('.timeline-table').find("#project-#{which}-menu")
    $(link).after($menu)

  # Don't do anything with clicks on menu links that are set to disabled.
  handleDisabledMenuLinkClick: (e) ->
    e.stopPropagation()

  stepIdFromEvent: (e) ->
    @$(e.currentTarget).closest('[data-id]').data('id')

  stepParentIdFromEvent: (e) ->
    @$(e.currentTarget).closest('[data-parent-id]').data('parent-id')

  duplicateStep: (e) ->
    @duplicateStepModal.show(e, @stepIdFromEvent(e), @refresh.bind(@))

  showPrecedentStep: (e) ->
    $step = @$(e.currentTarget)
    precedentId = $step.data('precedent-id')
    $table = $step.closest('tbody')

    $precedent = $table.find(".step-end-date[data-id=#{precedentId}]")
    if $precedent.length
      $precedent.addClass('highlighted')
      $step.addClass('highlighted')

  showDependentSteps: (e) ->
    $step = @$(e.currentTarget)
    currentId = $step.data('id')
    $table = $step.closest('tbody')

    $dependents = $table.find(".step-start-date[data-precedent-id=#{currentId}]")
    if $dependents.length
      $dependents.addClass('highlighted')
      $step.addClass('highlighted')

  hideRelatedSteps: (e) ->
    $step = @$(e.currentTarget)
    $table = $step.closest('tbody')
    $table.find('td').removeClass('highlighted')

  openLogList: (e) ->
    e.preventDefault()
    stepId = @$(e.currentTarget).closest('td[data-id]').data('id')
    unless @logListModalView
      @logListModalView = new MS.Views.LogListModalView(el: @$('#log-list-modal'))
    @logListModalView.show(stepId, @refresh.bind(@))
