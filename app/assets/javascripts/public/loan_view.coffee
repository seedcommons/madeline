# For public loans
class MS.Views.LoanView extends Backbone.View

  el: '.loans'

  initialize: ->
    @initializeTabs()

  # events: ->

  initializeTabs: ->
    # Loan tabs use jQuery UI Tab functionality and Bootstrap styling
    @$el.find('#tabs').tabs();
