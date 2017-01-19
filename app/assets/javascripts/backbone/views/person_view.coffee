# Allows user specific fields to be hidden / show based on checkbox
class MS.Views.PersonView extends Backbone.View

  initialize: ->
    @showHideUserFields()

  events:
    'click #person_has_system_access': 'showHideUserFields'
    'click .notes .new-button': 'newNote'

  newNote: (e) ->
    newNote = @$('.new-note').children().clone()
    @$('.notes-inner').prepend(newNote)
    new MS.Views.NoteView(el: newNote)

  showHideUserFields: ->
    if @$('#person_has_system_access').is(':checked')
      @$('#user_fields').show()
    else
      @$('#user_fields').hide()
