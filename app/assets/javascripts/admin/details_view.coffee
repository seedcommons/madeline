class MS.Views.DetailsView extends Backbone.View

  el: 'section.details'

  initialize: (options) ->
    @loanId = options.loanId

    @refresh()

  refresh:  ->
    MS.loadingIndicator.show()
    @$('.loan-fields').empty()
    $.get "/admin/loans/#{@loanId}/details", (html) =>
      MS.loadingIndicator.hide()
      @$('.loan-fields').html(html)
