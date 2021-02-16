class MS.Views.LogListView extends Backbone.View

  initialize: (options) ->
    new MS.Views.AutoLoadingIndicatorView()
    @refreshUrl = options.refreshUrl
    @logFormModalView = new MS.Views.LogFormModalView(el: options.logFormModal, reloadOnSave: options.reloadOnSave)

  events:
    'click .log [data-action="edit"]': 'openEditLog'
    'confirm:complete .log [data-action="delete"]': 'deleteLog'

  openEditLog: (e) ->
    e.preventDefault()
    logId = @$(e.currentTarget).closest('.log').data('id')
    $('#project-step-modal').modal('hide')
    @logFormModalView.showEdit(logId, '', @refresh.bind(@))

  deleteLog: (e, resp) ->
    logId = @$(e.currentTarget).closest('.log').data('id')
    stepId = @$(e.currentTarget).closest('.log').data('step-id')
    context = @$(e.currentTarget).data('context')
    if (resp)
      $.ajax(method: "DELETE", url: "/admin/logs/#{logId}/?context=#{context}")
      .done (response) =>
        # Replace log list in step modal
        @$el.html(response)

        # Replace list of latest logs in timeline step
        timelineLogs = @$el.find(".timeline-latest-logs").html()
        @$el.closest(".content").find(".recent-logs[data-id='#{stepId}']").replaceWith(timelineLogs)

        # Replace number of logs in calendar step event
        calendarLogs = @$el.find(".calendar-logs").html()
        calendarEvent = @$el.closest(".content").find(".calendar-event.project-step[data-id='#{stepId}']")
        calendarEvent.find(".calendar-logs").replaceWith(calendarLogs)

      .fail (response) -> MS.alert(response.responseText)

#  the last bit is to fix the refresh since it breaks the step modal log list on delete
  refresh: () ->
    $.get @refreshUrl, (html) =>
      @$el.html(html)
      @afterRefresh() if @afterRefresh
