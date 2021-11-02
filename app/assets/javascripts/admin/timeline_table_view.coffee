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
    @styleDropdowns()

  events:
    # Timeline actions
    'click .timeline-action[data-action="new-group"]': 'newGroup'
    'click .timeline-action[data-action="new-step"]': 'newStep'
    # Group actions
    'click .project-group .fa-cog': 'openGroupMenu'
    'click .project-group-item[data-action="edit"]': 'editGroup'
    'click #project-group-menu [data-action="add-child-group"]': 'newChildGroup'
    'click #project-group-menu [data-action="add-child-step"]': 'newChildStep'
    'click #project-group-menu [data-action="delete"]': 'hideGroupMenu'
    'confirm:complete #project-group-menu [data-action="delete"]': 'deleteGroup'
    # Step actions
    'click .step-menu-col .fa-cog': 'openStepMenu'
    'click .project-step-item': 'showStep'
    'click #project-step-menu a[data-action=add-log]': 'addLog'
    'click #project-step-menu a[data-action=add-dependent-step]': 'addDependentStep'
    'click #project-step-menu a[data-action=duplicate]': 'duplicateStep'
    'click #project-step-menu [data-action="delete"]': 'hideStepMenu'
    'confirm:complete #project-step-menu [data-action="delete"]': 'deleteStep'
    # Step interactions
    'mouseenter .step-start-date': 'showPrecedentStep'
    'mouseenter .step-end-date': 'showDependentSteps'
    'mouseleave .step-date': 'hideRelatedSteps'
    'mouseenter td.project-step': 'highlightStep'
    'mouseleave td.project-step': 'unhighlightStep'
    # Logs list actions
    'click [data-action="view-logs"]': 'openLogList'
    # Other actions
    'click ul.dropdown-menu li.disabled a': 'handleDisabledMenuLinkClick'
    'change form.filters': 'refresh'

  refresh: ->
    MS.loadingIndicator.show()
    $.get "/admin/projects/#{@projectId}/timeline#{window.location.search}", (html) =>
      MS.loadingIndicator.hide()
      @$('.table-wrapper').html(html)
      @timelineFilters.resetFilterDropdowns()
      @styleDropdowns()

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
    if @$(e.target).hasClass('project-group-item')
      e.preventDefault()
      @groupModal.edit(@parentId(e))

  deleteGroup: (e, response) ->
    e.preventDefault()
    if (response)
      $.post("/admin/project_groups/#{@parentId(e)}", {'_method': 'DELETE'})
      .done => @refresh()
      .fail (response) => MS.alert(response.responseText)

  newStep: (e) ->
    e.preventDefault()
    @stepModal.new(@projectId, @refresh.bind(@))

  showStep: (e) ->
    if @$(e.target).hasClass('project-step-item')
      e.preventDefault()
      e.stopPropagation() # Don't propagate clicks on 'Show' in dropdown up to td element.
      @stepModal.show(@stepIdFromEvent(e), @refresh.bind(@))

  addLog: (e) ->
    e.preventDefault()
    unless @logFormModalView
      @logFormModalView = new MS.Views.LogFormModalView(el: $("<div>").insertAfter(@$el))
    @logFormModalView.showNew(@stepIdFromEvent(e), @refresh.bind(@))

  deleteStep: (e, resp) ->
    item = e.currentTarget
    stepId = $(item).closest('.step-menu-col').data('id')
    if (resp)
      $.ajax(type: "DELETE", url: "/admin/project_steps/#{stepId}")
      .done =>
        @refresh()
      .fail (response) ->
        MS.alert(response.responseText)

  addDependentStep: (e) ->
    e.preventDefault()
    @stepModal.new(@projectId, @refresh.bind(@),
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
    $logsLink = @$('#project-step-menu a[data-action="view-logs"]').closest('li')

    if !(@$(e.currentTarget).closest('.step-menu-col').hasClass('logs-available'))
      $logsLink.addClass('disabled')
    else
      $logsLink.removeClass('disabled')

    @openMenu(e, 'step')

  openMenu: (e, which) ->
    link = e.currentTarget
    $menu = $(link).closest('.timeline-table').find("#project-#{which}-menu")
    $(link).after($menu)
    $menu.toggle()

  hideStepMenu: (e) ->
    @hideMenu(e, 'step')

  hideGroupMenu: (e) ->
    @hideMenu(e, 'group')

  hideMenu: (e, which) ->
    @$("#project-#{which}-menu").hide()

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
    $logsLink = @$('#project-step-menu a[data-action="view-logs"]').closest('li')

    e.preventDefault()

    if !$logsLink.hasClass('disabled')
      @stepModal.show(@stepIdFromEvent(e), @refresh.bind(@), {expandedLogs: true})

  styleDropdowns: ->
    # Make top 4 rows of timeline have dropdown menus instead of dropup menus
    $topRows = @$el.find('tbody tr:nth-child(-n+4)')
    $topGroups = $topRows.find('.project-group')
    $topGroups.removeClass('dropup')
    $topSteps = $topRows.find('.step-menu-col')
    $topSteps.removeClass('dropup')

  highlightStep: (e) ->
    id = $(e.currentTarget).data('id')
    @$("td.project-step[data-id='#{id}']").addClass('highlighted2')

  unhighlightStep: (e) ->
    id = $(e.currentTarget).data('id')
    @$("td.project-step[data-id='#{id}']").removeClass('highlighted2')
