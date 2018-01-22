class MS.Views.ProjectStepModalView extends Backbone.View

  el: '#project-step-modal'

  initialize: (params) ->
    new MS.Views.AutoLoadingIndicatorView()
    @done = (->) # Empty function

  events:
    'click .cancel': 'close'
    'click .submit': 'submitForm'
    'ajax:complete form': 'submitComplete'
    'confirm:complete a.delete-action': 'delete'
    'change #project_step_scheduled_duration_days': 'setScheduledEndDate'
    'change #project_step_schedule_parent_id': 'setScheduledStartDateOnDependent'
    'change #project_step_scheduled_start_date': 'setStaticStartDate'

  show: (id, done, options = {}) ->
    @done = done
    @expandedLogs = options.expandedLogs
    # The show method is only used by the calendar. Hopefully contexts can go away later.
    @loadContent("/admin/project_steps/#{id}?context=calendar")

  new: (projectId, done, options = {}) ->
    @done = done
    date = options.date || ''
    parentId = options.parentId if options.parentId
    precedentId = options.precedentId if options.precedentId
    urlParams = "?project_id=#{projectId}&context=timeline_table&date=#{date}&parent_id=#{parentId}&schedule_parent_id=#{precedentId}"
    @loadContent("/admin/project_steps/new#{urlParams}")

  edit: (id, done) ->
    @done = done
    @loadContent("/admin/project_steps/#{id}/edit?context=timeline_table")

  delete: (e, resp) ->
    id = @$(e.currentTarget).closest('[data-id]').data('id')
    if (resp)
      $.post "/admin/project_steps/#{id}", {'_method': 'DELETE'}, =>
        @close()
        @runAndResetDoneCallback()

  close: ->
    @$el.modal('hide')

  submitForm: ->
    @$('form').submit()

  submitComplete: (e, data) ->
    if parseInt(data.status) == 200 # data.status is sometimes a string, sometimes an int!?
      @close()
      json = data.responseJSON || {}
      # If the step date or duration changed as a result of the update,
      # we need to show the step move modal, which prompts for a new log.
      if json.days_shifted || json.duration_changed
        @showMoveStepModal(json.id, json.days_shifted)
      else
        @runAndResetDoneCallback()
    else
      @replaceContent(data.responseText)

  loadContent: (url) ->
    $.get url, (html) =>
      @replaceContent(html)
      @$el.modal('show')

  replaceContent: (html) ->
    @$el.find('.modal-content').html(html)
    new MS.Views.TranslationsView(el: @$('[data-content-translatable="project_step"]'))
    @showHideStartDate()
    @expandLogs() if @expandedLogs

  showMoveStepModal: (id, daysShifted) ->
    unless @moveStepModal
      el = $('<div>').insertAfter(@$el)
      @moveStepModal = new MS.Views.MoveStepModalView(el: el, context: 'edit_date')
    @moveStepModal.show(id, daysShifted).done => @runAndResetDoneCallback()

  runAndResetDoneCallback: ->
    @done()
    @done = (->) # Reset to empty function.

  setScheduledEndDate: ->
    # Applies to all steps
    # Takes the current start date plus current duration and changes the end date

    startDateVal = @$('#project_step_scheduled_start_date').val()
    duration = Number(@$('#project_step_scheduled_duration_days').val())

    startDate = new Date(startDateVal)

    preEndDate = new Date(startDate.setDate(startDate.getDate() + duration))

    if startDateVal
      # if duration has not been set in the ui, js has this stored as 0 in memory
      # this condition is in order for the end date not to be set to a day before
      if duration < 1
        endDate = startDate
      else
        endDate = preEndDate.setDate(preEndDate.getDate() - 1)

      endDateMoment = moment(endDate)
      endDateFormatted = moment(endDateMoment).format(MS.dateFormats.default)

      @$(".form-group.project_step_scheduled_end_date").find(".static-text-as-field").
        html(endDateFormatted)

  setScheduledStartDateOnDependent: ->
    # Applies to dependent step only
    # Set start date to the precedent step end date plus 1
    precedentId = @$('#project_step_schedule_parent_id').val()
    if precedentId
      startDate = $(".step-end-date[data-id=#{precedentId}]").data('dependent-step-start-date')
      @$(".project_step_scheduled_start_date").find(".static-text-as-field").html(startDate)
      @$("#project_step_scheduled_start_date").val(startDate)

    @setScheduledEndDate()
    @showHideStartDate()

  showHideStartDate: ->
    # Show read-only start date when step has precedent step
    # Show editable start date when step is not a dependent step
    precedentId = @$('#project_step_schedule_parent_id').val()

    if precedentId
      @$(".project_step_scheduled_start_date").find(".static-text-as-field").show()
      @$("#project_step_scheduled_start_date").hide()
    else
      @$(".project_step_scheduled_start_date").find(".static-text-as-field").hide()
      @$("#project_step_scheduled_start_date").show()

  setStaticStartDate: ->
    # Sync user inputed start date with hidden read-only start date
    userStartDate = @$("#project_step_scheduled_start_date").val()
    staticStartDate = @$(".project_step_scheduled_start_date").find(".static-text-as-field").html()

    if userStartDate != staticStartDate
      @$(".project_step_scheduled_start_date").find(".static-text-as-field").html(userStartDate)

    @setScheduledEndDate()
    @showHideStartDate()

  expandLogs: ->
    @$("[data-expands]").click()
