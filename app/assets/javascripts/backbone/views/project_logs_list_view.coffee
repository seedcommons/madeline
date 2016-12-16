class MS.Views.ProjectLogsListView extends Backbone.View

  el: '.loan-content #logs'

  initialize: (options) ->
    @loanId = options.loanId
    @refresh()

  refresh: ->
    $.get "/admin/logs?loan=#{@loanId}&per_page=50", (html) =>
      MS.loadingIndicator.hide()
      @$('.logs-list').html(html)
