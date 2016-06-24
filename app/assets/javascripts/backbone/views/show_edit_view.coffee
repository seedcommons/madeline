# Toggles between show and edit modes for a show/edit view
class MS.Views.ShowEditView extends Backbone.View

  events:
    'click .edit-action': 'showEdit'
    'click .show-action': 'showShow'

  showEdit: (e) ->
    console.log('showEdit')
    @$el.addClass('edit-view').removeClass('show-view')
    # needed for loan criteria.  both the '.loan.details' and 'section.criteria' need to be updated
    auxBlock = $(e.currentTarget).attr('aux-block')
    if auxBlock
      $(auxBlock).addClass('edit-view').removeClass('show-view')
    unless $(e.currentTarget).attr('suppress-show-edit-tab') == 'true'
      $('.edit-tab').tab 'show'

  showShow: ->
    @$el.addClass('show-view').removeClass('edit-view')
