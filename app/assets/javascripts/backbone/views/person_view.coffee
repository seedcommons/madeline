# Allows user specific fields to be hidden / show based on checkbox
class MS.Views.PersonView extends Backbone.View

  initialize: ->
    @showHideUserFields()
    new MS.Views.NotableView({ el: @el })

  events:
    'click #person_has_system_access': 'showHideUserFields'

  showHideUserFields: ->
    if @$('#person_has_system_access').is(':checked')
      @$('#user_fields').show()
    else
      @$('#user_fields').hide()
