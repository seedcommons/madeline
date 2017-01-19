class MS.Views.NotableView extends Backbone.View

  initialize: (params) ->
    new MS.Views.AutoLoadingIndicatorView()

  events:
    'click .notes .new-link': 'newNote'

  newNote: (e) ->
    newNote = @$('.new-note').children().clone()
    @$('.notes-inner').prepend(newNote)
    new MS.Views.NoteView(el: newNote)
    false
