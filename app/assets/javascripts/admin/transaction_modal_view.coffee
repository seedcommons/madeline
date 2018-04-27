class MS.Views.TransactionModalView extends Backbone.View
  el: '#transaction-modal'

  events:
    'click [data-action="submit"]': 'submitForm'
    'ajax:complete form': 'submitComplete'
    'change #accounting_transaction_loan_transaction_type_value': 'setDescription'

  new: (loanId) ->
    @loanId = loanId
    url = "/admin/accounting/transactions/new"
    @loadContent(url, loanId, 'new')

  show: (id, loanId) ->
    @loanId = loanId
    url = "/admin/loans/#{loanId}/transactions/#{id}"
    @loadContent(url, loanId, 'show')

  loadContent: (url, loanId, action) ->
    $.get url, project_id: loanId, (html) =>
      @replaceContent(html, action)
      @$el.modal('show')

  replaceContent: (html, action) ->
    @$el.find('.modal-content').html(html)
    @$el.removeClass('new-view show-view edit-view')
    @$el.addClass("#{action}-view")

  submitForm: ->
    MS.loadingIndicator.show()
    @$('form').submit()

  submitComplete: (e, data) ->
    if parseInt(data.status) == 200
      @$el.modal('hide')
      window.location.reload(true)
    else
      MS.loadingIndicator.hide()
      @$('.modal-content').html(data.responseText)

  setDescription: (e) ->
    if e.target.value != ''
      description = I18n.t('transactions.default_description',
        loan_transaction_type: e.target.selectedOptions[0].innerText, loan_id: @loanId)
    else
      description = ''
    $('#accounting_transaction_description').val(description)
