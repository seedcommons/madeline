class MS.Views.OrganizationView extends Backbone.View

  el: '.coop'

  initialize: (params) ->
    new MS.Views.AutoLoadingIndicatorView()

  events:
    'click .notes .new-button': 'newNote'

  newNote: (e) ->
    $new_note = @$('.new-note').appendTo(@$('.notes'))
    new MS.Views.NoteView(el: $new_note)
