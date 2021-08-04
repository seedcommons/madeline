class MS.Views.TransactionModalView extends Backbone.View
  el: '#transaction-modal'

  events:
    'click [data-action="submit"]': 'submitForm'
    'ajax:complete form': 'submitComplete'
    'change .accounting_transaction_loan_transaction_type_value': 'updateDisbursementFieldVisibility'
    'change .accounting_transaction_disbursement_type': 'updateCheckFieldVisibility'

  initialize: (params) ->
    @loanId = params.loanId
    @locale = params.locale

  showModal: (txn_id, action) ->
    if action == "new"
      url = "/admin/accounting/transactions/new"
    else
      url = "/admin/loans/#{@loanId}/transactions/#{txn_id}"
    @loadContent(url, @loanId, action)

  loadContent: (url, loanId, action) ->
    $.get url, project_id: loanId, (html) =>
      @replaceContent(html, action)
      @$el.modal('show')
      if action == "new"
        @$('.disbursement-only').hide()
        @$('.check-only').hide()

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

  clearCheckField: ->
    @$('#accounting_transaction_disbursement_type_check').prop("checked", false)
    @$('.check-only').hide()

  updateDisbursementFieldVisibility: (e) ->
    if e.target.value == "disbursement"
      @$('.disbursement-only').show()
    else
      @$('.disbursement-only').hide()
      @clearCheckField()

  updateCheckFieldVisibility: (e) ->
    if e.target.value == "check"
      @$('.check-only').show()
    else
      @clearCheckField()

  setDescription: (e) ->
    if e.target.value != ''
      description = I18n.t('transactions.default_description',
        loan_transaction_type: e.target.selectedOptions[0].innerText, loan_id: @loanId, locale: @locale)
    else
      description = ''
    $('#accounting_transaction_description').val(description)
