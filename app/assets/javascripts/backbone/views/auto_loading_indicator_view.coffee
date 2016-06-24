class MS.Views.AutoLoadingIndicatorView extends Backbone.View
  # Instantiate this class in a view to make the loading indicator show and hide
  # automatically with every ajax request

  initialize: ->
    $(document)
      .ajaxStart ->
        MS.loadingIndicator.show()
      .ajaxStop ->
        MS.loadingIndicator.hide()
