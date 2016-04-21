class MS.Views.TimelineHeaderView extends Backbone.View

  el: 'body'

  events: (params) ->
    'click .filter .btn': 'filterSteps'
    'click #edit-all': 'editAll'
    'click #edit-all-cancel': 'cancelEdit'

  initialize: ->
    $('#edit-all-cancel').hide()
    $('#save-all').hide()

  filterSteps: (e) ->
    item = e.currentTarget
    selected = $(item).find('input')[0].value
    if selected == "incomplete"
      $('.step.completed').hide()
    else if selected == "all"
      $('.step').show()

  editAll: (e) ->
    e.preventDefault()
    $('.view-step-block').hide()
    $('.form-step-block').show()

    $('#edit-all').hide()
    $('#new-step').hide()
    $('#edit-all-cancel').show()
    $('#save-all').show()

  cancelEdit: (e) ->
    e.preventDefault()
    $('.view-step-block').show()
    $('.form-step-block').hide()

    $('#edit-all').show()
    $('#new-step').show()
    $('#edit-all-cancel').hide()
    $('#save-all').hide()
