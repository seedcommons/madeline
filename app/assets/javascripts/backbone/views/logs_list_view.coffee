class MS.Views.LogsListView extends Backbone.View

  initialize: (options) ->
    @loanId = options.loanId if options.loanId
    @refresh()

  refresh: ->
    $.get "/admin/logs?loan=#{@loanId}&per_page=50", (html) =>
      MS.loadingIndicator.hide()
      @$('.logs-list').html(html)
