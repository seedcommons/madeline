class MS.Views.TransactionModalView extends Backbone.View
  el: '#transaction-modal'

  events:
    'click .btn-primary': 'submitForm'
    'ajax:complete form': 'submitComplete'

  initialize: (params) ->
    @loanId = params.loanId

  submitForm: ->
    MS.loadingIndicator.show()
    @$('form').submit()

  submitComplete: (e, data) ->
    MS.loadingIndicator.hide()
    if parseInt(data.status) == 200 # data.status is sometimes a string, sometimes an int!?
      @$el.modal('hide')
    else
      @$('.modal-content').html(data.responseText)
