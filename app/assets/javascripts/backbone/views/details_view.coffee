class MS.Views.DetailsView extends Backbone.View

  el: 'section.details'

  initialize: (options) ->
    @projectId = options.projectId

    @refresh()

  refresh:  ->
    MS.loadingIndicator.show()
    @$('.loan-fields').empty()
    $.get "/admin/loans/#{@projectId}/details", (html) =>
      MS.loadingIndicator.hide()
      @$('.loan-fields').html(html)
