class MS.Views.OrganizationView extends Backbone.View

  el: '.coop'

  initialize: (params) ->
    new MS.Views.AutoLoadingIndicatorView()

  events:
    'click .notes .new-button': 'newNote'

  newNote: (e) ->
    newNote = @$('.new-note').children().clone()
    @$('.notes-inner').prepend(newNote)
    new MS.Views.NoteView(el: newNote)
