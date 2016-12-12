class MS.Views.LogsListView extends Backbone.View

  initialize: (options) ->
    @loanId = options.loanId if options.loanId
    @stepId = options.stepId if options.stepId
    @refresh()

  refresh: ->
    if @stepId
      urlParams = "step=#{@stepId}"
    else
      urlParams = "loan=#{@loanId}"

    $.get "/admin/logs?#{urlParams}&per_page=50", (html) =>
      MS.loadingIndicator.hide()
      @$('.logs-list').html(html)
