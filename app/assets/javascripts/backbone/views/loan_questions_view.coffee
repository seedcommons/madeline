class MS.Views.LoanQuestionsView extends Backbone.View

  initialize: (params) ->
    $('.jqtree').tree({
      data: $('.jqtree').data('data')
      dragAndDrop: true
    })

  # events: ->
