class MS.Views.TransactionsView extends Backbone.View
  el: '.transactions'

  events:
   'click [data-action="new-transaction"]': 'newTransaction'

  newTransaction: ->
    @$('#transaction-modal').modal('show')

  showTransaction: ->
    @$('#transaction-modal').modal('show')

  # loadContent: (url) ->
  #   $.get url, (html) =>
  #     @replaceContent(html)
  #     @$el.modal('show')
  #
  # replaceContent: (html) ->
  #   @$el.find('.modal-content').html(html)
  #   new MS.Views.TranslationsView(el: @$('[data-content-translatable="project_step"]'))
  #   @showHideStartDate()
