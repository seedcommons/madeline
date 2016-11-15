# Handles showing, hiding, formatting, and submitting of project step form
class MS.Views.ProjectStepView extends Backbone.View

  TYPE_ICONS:
    'checkin': 'calendar-check-o'
    'milestone': 'flag'

  initialize: (params) ->
    @initTypeSelect()
    @persisted = params.persisted
    @duplicate = params.duplicate
    @timelineTableView = params.timelineTableView
    unless @timelineTableView
      @context = @$el.data('context')
    @daysShifted = params.daysShifted
    @stepId = params.stepId
    new MS.Views.TranslationsView(el: @$('[data-content-translatable="project_step"]'))
    @showMoveStepModal()

  events:
    'click a.edit-step-action': 'showForm'
    'click a.duplicate-step-action': 'showDuplicateModal'
    'click a.cancel': 'cancel'
    'submit form.project-step-form': 'onSubmit'
    'ajax:success': 'ajaxSuccess'
    'click [data-action="add-log"]': 'showLogModal'
    'click [data-action="edit-log"]': 'showLogModal'
    'confirm:complete [data-action="delete-log"]': 'deleteLog'

  showForm: (e) ->
    e.preventDefault()
    @$('.view-step-block').hide()
    @$('.form-step-block').show()

  cancel: (e) ->
    if @context == 'timeline'
      e.preventDefault()
      if @persisted
        @$('.view-step-block').show()
        @$('.form-step-block').hide()
      else
        MS.timelineView.removeStep(@$el)

  showDuplicateModal: (e) ->
    e.preventDefault()
    MS.loadingIndicator.show()

    # TODO: Add conditional to only do this in timeline table context
    $.get "/admin/project_steps/#{@stepId}/show_duplicate", (html) =>
      $('.timeline-table .modal.duplicate-step').replaceWith(html)
      $('.timeline-table .modal.duplicate-step').modal('show')
    # else
    #   @$('.duplicate-step').modal('show')

  # Select 2 is used to show the pretty icons.
  initTypeSelect: ->
    @$('.type').select2({
      theme: "bootstrap",
      minimumResultsForSearch: Infinity,
      width: "100%",
      templateResult: (option) => @formatTypeOptions(option),
      templateSelection: (option) => @formatTypeOptions(option)
    });

  formatTypeOptions: (option) ->
    if icon = @TYPE_ICONS[option.id]
      $("<i class=\"fa fa-#{icon}\"></i> <span>#{option.text}</span>")
    else
      $("<span>#{option.text}</span>")

  onSubmit: ->
    MS.loadingIndicator.show()

  ajaxSuccess: (e, data) ->
    if $(e.target).is('form.project-step-form')
      MS.loadingIndicator.hide()
      if @context == 'timeline'
        @replaceWith(data)
        MS.timelineView.addBlankStep() unless @persisted || @duplicate
      else
        $('#calendar-step-modal').modal('hide')
        MS.calendarView.refresh()

    else if $(e.target).is('a.action-delete')
      MS.calendarView.refresh() if @context == "calendar"
      @$el.remove()

  replaceWith: (html) ->
    @$el.replaceWith(html)

  showLogModal: (e) ->
    e.preventDefault()
    link = e.currentTarget
    action = @$(link).data('action')

    if @timelineTableView
      stepId = @stepId
    else
      stepId = @$(link).data('parent-step-id')

    unless @logModalView
      if @timelineTableView
        @logModalView = new MS.Views.LogModalView(el: $('.timeline-table .log-modal'), timelineTableView: @timelineTableView)
      else
        @logModalView = new MS.Views.LogModalView(el: $("<div>").appendTo(@$el), parentView: this)

    if action == "edit-log"
      @logModalView.showEdit(@$(link).data('log-id'), stepId)
    else
      @logModalView.showNew(stepId)

  deleteLog: (e, response) ->
    $.post @$(e.target).attr('href'), {_method: 'DELETE'}, (data) => @replaceWith(data)
    false

  # Show move step modal if step was just moved.
  showMoveStepModal: (e) ->
    if @daysShifted
      unless @moveStepModalView
        @moveStepModalView = new MS.Views.MoveStepModalView
          el: $("<div>").appendTo(@$el)
          context: 'edit_date'
      @moveStepModalView.show(@stepId, @daysShifted).done -> MS.timelineView.refreshSteps()
