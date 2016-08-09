class MS.Views.OrganizationView extends Backbone.View

  el: '.coop'

  initialize: (params) ->
    new MS.Views.AutoLoadingIndicatorView()

  events:
    'click .notes .new-button': 'newNote'

  newNote: (e) ->
    @$('.new-note').clone().appendTo(@$('.notes'))
