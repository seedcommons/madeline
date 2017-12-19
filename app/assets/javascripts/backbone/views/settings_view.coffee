class MS.Views.SettingsView extends Backbone.View
  initialize: ->
    new MS.Views.AutoLoadingIndicatorView()
    @setUpEventListener();

  setUpEventListener: ->
    $(window).one("focus", @checkQuickbooksConnected);

  checkQuickbooksConnected: (e) ->
    $.get '/admin/accounting/quickbooks/connected', (connected) =>
      location.reload() if(connected)
