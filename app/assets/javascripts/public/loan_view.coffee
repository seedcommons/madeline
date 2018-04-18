# For public loans
class MS.Views.LoanView extends Backbone.View

  el: '.loans'

  initialize: ->
    console.log("Initalized")
    @initializeTabs()

  # events: ->

  initializeTabs: ->
    console.log("Initalize Tabs")
    @$el.tabs();
