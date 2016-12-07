class MS.Views.ProjectLogsListView extends Backbone.View

  initialize: (options) ->
    @loanId = options.loanId
    @refresh()

  refresh: ->
    $.get "/admin/logs?loan=#{@loanId}", (html) =>
      MS.loadingIndicator.hide()
      $('#project-logs-list').html(html)
