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
    if parseInt(data.status) == 200
      @$el.modal('hide')
      window.location.reload(true)
    else
      @$('.modal-content').html(data.responseText)
