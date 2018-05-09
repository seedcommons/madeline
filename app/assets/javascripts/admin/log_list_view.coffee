class MS.Views.LogListView extends Backbone.View

  initialize: (options) ->
    new MS.Views.AutoLoadingIndicatorView()
    @refreshUrl = options.refreshUrl
    @logFormModalView = new MS.Views.LogFormModalView(el: options.logFormModal)

  events:
    'click .log [data-action="edit"]': 'openEditLog'
    'confirm:complete .log [data-action="delete"]': 'deleteLog'

  openEditLog: (e) ->
    e.preventDefault()
    logId = @$(e.currentTarget).closest('.log').data('id')
    @logFormModalView.showEdit(logId, '', @refresh.bind(@))

  deleteLog: (e, resp) ->
    logId = @$(e.currentTarget).closest('.log').data('id')
    stepId = @$(e.currentTarget).closest('.log').data('step-id')
    context = @$(e.currentTarget).data('context')
    if (resp)
      $.ajax(method: "DELETE", url: "/admin/logs/#{logId}/?context=#{context}")
      .done (response) =>
        # Replace log list
        @$el.html(response)
        timelineLogs = @$el.find(".timeline-latest-logs").html()
        console.log(timelineLogs)
        @$el.closest(".content").find(".recent-logs[data-id='#{stepId}']").replaceWith(timelineLogs)

        # Remove log from timeline
        # @$el.closest(".content").find(".project-step .log-summary[data-log-id='#{logId}']").remove()
        # logs_length = @$el.closest(".content").find(".project-step .log-summary").length
        # console.log logs_length
        # # If no more logs exist, do not show the 'More' link
        # if logs_length < 1
        #   @$el.closest(".content").find(".recent-logs[data-id='#{stepId}']").empty()

      .fail (response) -> MS.alert(response.responseText)

#  the last bit is to fix the refresh since it breaks the step modal log list on delete
  refresh: () ->
    $.get @refreshUrl, (html) =>
      @$el.html(html)
      @afterRefresh() if @afterRefresh
