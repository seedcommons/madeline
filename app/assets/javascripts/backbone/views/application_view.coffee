# This view is for general functions for the entire app, including admin and frontend
# Should be used sparingly. Prefer separate views (perhaps instantiated from in here)
# for cohesive pieces of functionality.
class MS.Views.ApplicationView extends Backbone.View

  el: 'body'

  initialize: ->
    MS.loadingIndicator = @$('#glb-load-ind')
    MS.errorModal = @$('#glb-error-modal')

  events: ->
    'click .more': 'toggleExpanded'
    'click .less': 'toggleExpanded'

  toggleExpanded: (e) ->
    @$(e.currentTarget).closest(".expandable").toggleClass("expanded")
