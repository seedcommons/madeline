# Handles showing, hiding, formatting, and submitting of project step form
class MS.Views.ProjectStepView extends Backbone.View

  TYPE_ICONS:
    'checkin': 'calendar-check-o'
    'milestone': 'flag'

  initialize: (params) ->
    @initTypeSelect()
    @persisted = params.persisted
    @duplicate = params.duplicate
    @context = @$el.data('context')
    @daysShifted = params.daysShifted
    @stepId = params.stepId
    new MS.Views.TranslationsView(el: @$('[data-content-translatable="step"]'))
    @showShiftDatesModal()

  events:
    'click a.edit-step-action': 'showForm'
    'click a.duplicate-step-action': 'showDuplicateModal'
    'click a.cancel': 'cancel'
    'submit form': 'onSubmit'
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
    @$('.duplicate-step').modal('show')

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
    if $(e.target).is('form')
      MS.loadingIndicator.hide()

      if @context == 'timeline'
        @replaceWith(data)
        MS.timelineView.addBlankStep() unless @persisted || @duplicate
      else
        $('#calendar-step-modal').modal('hide')
        MS.calendarView.refresh()

    else if $(e.target).is('a.action-delete')
      MS.calendarView.refresh()
      @$el.remove()

  replaceWith: (html) ->
    @$el.replaceWith(html)

  showLogModal: (e) ->
    e.preventDefault()
    link = e.currentTarget
    action = @$(link).data('action')

    @modalView = new MS.Views.LogModalView(parentView: this) unless @modalView

    if action == "edit-log"
      @modalView.showEdit(@$(link).data('log-id'), @$(link).data('parent-step-id'))
    else
      @modalView.showNew(@$(link).data('parent-step-id'))

  deleteLog: (e, response) ->
    $.post @$(e.target).attr('href'), {_method: 'DELETE'}

    # Number of logs currently visible includes one just deleted from database
    logsList = @$(e.target).closest('.logs-list')
    numOfLogs = @$(logsList).children().length

    if numOfLogs < 2
      logContainer = @$(logsList).closest('.step-logs')
      @$(logContainer).removeClass('expanded')
      @$(logContainer).find('.view-logs-ctrl').html('<span class="no-logs">No Logs</span>')

    @$(e.target).closest('.log').remove()
    false

  showShiftDatesModal: (e) ->
    if ((@daysShifted > 0))
      $("#step-shift-subsequent-confirm-modal-#{@stepId}").modal("show")
