class MS.Views.LogListView extends Backbone.View

  initialize: (options) ->
    new MS.Views.AutoLoadingIndicatorView()
    @refreshUrl = options.refreshUrl
    @logFormModalView = new MS.Views.LogFormModalView(el: options.logFormModal)

  events:
    'click .log [data-action="edit"]': 'openEditLog'
    'click .log [data-action="delete"]': 'prepareToDeleteLog'
    'confirm:complete .log [data-action="delete"]': 'deleteLog'

  openEditLog: (e) ->
    e.preventDefault()
    logId = @$(e.currentTarget).closest('.log').data('id')
    @logFormModalView.showEdit(logId, '', @refresh.bind(@))

  prepareToDeleteLog: (e) ->
    console.log(e)
    @logId = @$(e.currentTarget).closest('.log').data('id')
    console.log(@$(e.currentTarget))
    #@logId = @$(e.currentTarget).data('id')
    console.log(@logId)

  deleteLog: (e, resp) ->
    console.log(@logId)
    # e.preventDefault()
    logId = @$(e.currentTarget).closest('.log').data('id')
    console.log 'log id', logId
    if (resp)
      $.ajax(method: "DELETE", url: "/admin/logs/#{@logId}")
      .done => done
      .fail (response) -> MS.alert(response.responseText)

  # deleteLog: (e, resp, done) ->
  #   console.log(@logId)
  #   console.log('llv', e)
  #   e.preventDefault()
  #   logId = @$(e.currentTarget).closest('.log').data('id')
  #   console.log 'log id', logId
  #   if (resp)
  #     $.ajax(method: "DELETE", url: "/admin/logs/#{@logId}")
  #     .done => done
  #     .fail (response) -> MS.alert(response.responseText)

#  the last bit is to fix the refresh since it breaks the step modal log list on delete
  refresh: () ->
    $.get @refreshUrl, (html) =>
      @$el.html(html)
      @afterRefresh() if @afterRefresh

  onCompleteAction: (context, done) ->
#    if context == "timeline"
      # do an action from the timeline
      # close the project step modal
      # reload timeline
#    if context == "calendar"
      # do an action from the calendar
      # close the project step modal
      # reload calendar events
#    else
#      @refresh()
