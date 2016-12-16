# Handles the modal that shows a list of ProjectLogs.
class MS.Views.LogListModalView extends Backbone.View

  initialize: ->
    @logFormModalView = new MS.Views.LogFormModalView(el: $("<div>").insertAfter(@$el))

  show: (stepId) ->
    MS.loadingIndicator.show()
    @$el.modal('show')

    view = new MS.Views.LogListView(
      el: @$('section.log-list'),
      logFormModalView: @logFormModalView,
      refreshUrl: "/admin/logs?step=#{stepId}"
    )
    view.refresh()
