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
    console.log 'log id', logId
    if (resp)
      $.ajax(method: "DELETE", url: "/admin/logs/#{logId}")
      .done =>
        console.log("The log will be removed from the DOM")
        @$(".log[data-id='#{logId}']").remove()
      .fail (response) -> MS.alert(response.responseText)

#  the last bit is to fix the refresh since it breaks the step modal log list on delete
  refresh: () ->
    $.get @refreshUrl, (html) =>
      @$el.html(html)
      @afterRefresh() if @afterRefresh
