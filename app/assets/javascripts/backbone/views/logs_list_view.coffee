class MS.Views.LogsListView extends Backbone.View

  el: '.logs-list'

  initialize: (options) ->
    @refreshUrl = options.refreshUrl

  events:
    'click .log [data-action="edit"]': 'openEditLog'
    'confirm:complete .log [data-action="delete"]': 'deleteLog'
    'ajax:complete': 'refresh'

  openEditLog: (e) ->
    e.preventDefault()
    logId = @$(e.currentTarget).closest('.log').data('id')

    MS.LogModalView = new MS.Views.LogModalView(el: '.log-modal')
    MS.LogModalView.showEdit(logId, '', @refresh.bind(@))

  deleteLog: (e) ->
    e.preventDefault()
    logId = @$(e.currentTarget).closest('.log').data('id')
    console.log(logId)

    $.ajax(type: "DELETE", url: "/admin/logs/#{logId}")
    .done =>
      @refresh()
    .fail (response) ->
      MS.alert(response.responseText)
    return false

  refresh: () ->
    MS.loadingIndicator.show()
    $.get @refreshUrl, (html) =>
      MS.loadingIndicator.hide()
      console.log(html)
      @$el.replaceWith(html)
