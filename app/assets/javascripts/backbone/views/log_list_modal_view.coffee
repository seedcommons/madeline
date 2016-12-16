# Handles the modal that shows a list of ProjectLogs.
class MS.Views.LogListModalView extends Backbone.View

  initialize: ->
    @logFormModalView = new MS.Views.LogFormModalView(el: $("<div>").insertAfter(@$el))
    @logListView = view = new MS.Views.LogListView(
      el: @$('section.log-list'),
      logFormModalView: @logFormModalView
    )

  show: (stepId) ->
    MS.loadingIndicator.show()
    @$el.modal('show')
    @logListView.refreshUrl = "/admin/logs?step=#{stepId}"
    @logListView.refresh()
