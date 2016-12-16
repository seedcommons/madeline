class MS.Views.LogsListView extends Backbone.View

  el: '.logs-list'

  initialize: (options) ->
    new MS.Views.AutoLoadingIndicatorView()
    @refreshUrl = options.refreshUrl

  events:
    'click .log [data-action="edit"]': 'openEditLog'
    'confirm:complete .log [data-action="delete"]': 'deleteLog'

  openEditLog: (e) ->
    e.preventDefault()
    logId = @$(e.currentTarget).closest('.log').data('id')
    logFormModalView = new MS.Views.LogFormModalView(el: $("<div>").insertAfter(@$el))
    logFormModalView.showEdit(logId, '', @refresh.bind(@))

  deleteLog: (e) ->
    e.preventDefault()
    logId = @$(e.currentTarget).closest('.log').data('id')
    $.ajax(method: "DELETE", url: "/admin/logs/#{logId}")
    .done => @refresh()
    .fail (response) -> MS.alert(response.responseText)

  refresh: () ->
    $.get @refreshUrl, (html) =>
      @$el.replaceWith(html)
      # Fixes modal overlay bug in some logs list contexts
      $('.modal').modal('hide')
