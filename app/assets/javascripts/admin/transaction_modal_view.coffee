class MS.Views.TransactionModalView extends Backbone.View
  el: '#transaction-modal'

  events:
    'click [data-action="submit"]': 'submitForm'
    'ajax:complete form': 'submitComplete'
    'change .accounting_transaction_loan_transaction_type_value': 'updateDisbursementFieldVisibility'
    'change .accounting_transaction_qb_object_subtype': 'updateCheckFieldVisibility'

  initialize: (params) ->
    console.log("in initialize")
    @loanId = params.loanId
    @locale = params.locale
    url = "/admin/accounting/transactions/new"
    @loadContent(url, @loanId, 'new')

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

  updateDisbursementFieldVisibility: (e) ->
    console.log("Updating disb field visibility")
    console.log(e.target.value)
    if e.target.value == "disbursement"
      @$('.accounting_transaction_qb_object_subtype').show()
      console.log("show subtype")
    else
      @$('.accounting_transaction_qb_object_subtype').hide()
      console.log("hide subtype")
      @$('.accounting_transaction_qb_vendor').hide()
      @$('.accounting_transaction_check_number').hide()
      console.log("hide vendor")
      console.log("hide check number")

  updateCheckFieldVisibility: (e) ->
    console.log("Updating check field visibility")
    console.log(e.target.value)
    if e.target.value == "Check"
      console.log("show check number")
      @$('.accounting_transaction_check_number').show()
    else
      console.log("hide check_number")
      @$('.accounting_transaction_check_number').hide()


  setDescription: (e) ->
    if e.target.value != ''
      description = I18n.t('transactions.default_description',
        loan_transaction_type: e.target.selectedOptions[0].innerText, loan_id: @loanId, locale: @locale)
    else
      description = ''
    $('#accounting_transaction_description').val(description)
