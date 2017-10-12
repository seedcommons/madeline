class MS.Views.TransactionsView extends Backbone.View
  el: '.transactions'

  initialize: ->
    @modal = @$('#transaction-modal')

  events:
   'click [data-action="new-transaction"]': 'newTransaction'
   'click [data-action="show-transaction"]': 'showTransaction'

  newTransaction: (e) ->
    url = "/admin/accounting/transactions/new"
    @loadContent(url)

  showTransaction: (e) ->
    e.preventDefault()
    row = e.currentTarget
    console.log($(row).data())

    id = $(row).data('id')
    projectId = $(row).data('projectId')
    url = "/admin/loans/#{projectId}/transactions/#{id}"

    @loadContent(url)

  loadContent: (url) ->
    $.get url, (html) =>
      @replaceContent(html)
      @modal.modal('show')

  replaceContent: (html) ->
    @modal.find('.modal-content').html(html)

  # Example of how to split transactionModalView from transactionsView
  # showTransactionModal: (e) ->
  #   e.preventDefault()
  #   link = e.currentTarget
  #   action = @$(link).data('action')
  #
  #   unless @logFormModalView
  #     @logFormModalView = new MS.Views.LogFormModalView(el: $("<div>").appendTo(@$el), parentView: this)
  #
  #   if action == "edit-log"
  #     @logFormModalView.showEdit(@$(link).data('log-id'), @$(link).data('parent-step-id'), '')
  #   else
  #     @logFormModalView.showNew(@$(link).data('parent-step-id'))
