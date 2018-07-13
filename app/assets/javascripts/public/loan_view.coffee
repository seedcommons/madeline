# For public loans
class MS.Views.LoanView extends Backbone.View

  el: '.loans'

  initialize: ->
    console.log("Inside LoanView")
    $('.carousel').carousel()
