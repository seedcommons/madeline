class MS.Views.TransactionsView extends Backbone.View
  el: '.transactions'

  events:
   'click [data-action="new-transaction"]': 'newTransaction'
   'click [data-action="show-transaction"]': 'showTransaction'

  newTransaction: ->
    @$('#transaction-modal').modal('show')

  showTransaction: (e) ->
    e.preventDefault()
    console.log(e)
    row = e.currentTarget
    console.log($(row).data())

    @$('#transaction-modal').modal('show')
  #
  # loadContent: (url) ->
  #   $.get url, (html) =>
  #     @replaceContent(html)
  #     @$el.modal('show')
  #
  # replaceContent: (html) ->
  #   @$el.find('.modal-content').html(html)
  #   new MS.Views.TranslationsView(el: @$('[data-content-translatable="project_step"]'))
  #
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
