# The QuickBooks connection flow uses a pop up window to connect the accounts
# when the pop up window is closed, the madeline window receives focus again
# whenever the madeline settings window receives focus again (if quickbooks was disconnected)
# we check the new "connected" endpoint and if it is now connected, we refresh the page
class MS.Views.SettingsView extends Backbone.View
  initialize: (params) ->
    new MS.Views.AutoLoadingIndicatorView()
    @setUpEventListener() unless params.qb_connected

  setUpEventListener: ->
    $(window).one("focus", @checkQuickbooksConnected)

  checkQuickbooksConnected: (e) ->
    $.get '/admin/accounting/quickbooks/connected', (connected) =>
      location.reload() if connected
