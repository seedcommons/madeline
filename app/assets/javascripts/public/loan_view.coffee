# This view is for general functions for the entire app, including admin and frontend
# Should be used sparingly. Prefer separate views (perhaps instantiated from in here)
# for cohesive pieces of functionality.
class MS.Views.LoanView extends Backbone.View

  el: '.loans'

  initialize: ->
    console.log("Initalized")
    @initializeTabs()

  # events: ->

  initializeTabs: ->
    console.log("Initalize Tabs")
    @$el.tabs();
