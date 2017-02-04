# Handles the modal that shows a list of ProjectLogs.
class MS.Views.LogListModalView extends Backbone.View

  initialize: ->
    @logFormModal = $("<div>").insertAfter(@$el)
    @logListView = view = new MS.Views.LogListView(
      el: @$('section.log-list'),
      logFormModal: @logFormModal
    )

  show: (stepId, afterRefresh) ->
    MS.loadingIndicator.show()
    @$el.modal('show')
    @logListView.refreshUrl = "/admin/logs?step=#{stepId}"
    @logListView.refresh()
    @logListView.afterRefresh = afterRefresh
