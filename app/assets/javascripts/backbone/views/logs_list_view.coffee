class MS.Views.LogsListView extends Backbone.View

  el: '.logs-list'

  initialize: (options) ->
    @refreshUrl = options.refreshUrl

  events:
    'click .log [data-action="edit"]': 'openEditLog'
    'ajax:complete': 'refresh'

  openEditLog: (e) ->
    e.preventDefault()
    logId = @$(e.currentTarget).closest('.log').data('id')

    MS.LogModalView = new MS.Views.LogModalView(el: '.log-modal')
    MS.LogModalView.showEdit(logId, '', @refresh.bind(@))

  refresh: () ->
    MS.loadingIndicator.show()
    $.get @refreshUrl, (html) =>
      MS.loadingIndicator.hide()
      console.log(html)
      @$el.replaceWith(html)
