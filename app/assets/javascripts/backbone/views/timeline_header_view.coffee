class MS.Views.TimelineHeaderView extends Backbone.View

  el: 'body'

  events: ->
    'click #edit-all': 'editAll'
    'click #edit-all-cancel': 'cancelEdit'
    'click #save-all': 'saveAll'
    'click #show-all-logs': 'showAllLogs'
    'click #hide-all-logs': 'hideAllLogs'

  initialize: ->
    $('#edit-all-cancel').hide()
    $('#save-all').hide()
    $('#hide-all-logs').hide()

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
    $('.new-record').closest('.form-step-block').show()

    $('#edit-all').show()
    $('#new-step').show()
    $('#edit-all-cancel').hide()
    $('#save-all').hide()

  saveAll: (e) ->
    e.preventDefault()
    $('.project-step-form').submit()

    $('#edit-all').show()
    $('#new-step').show()
    $('#edit-all-cancel').hide()
    $('#save-all').hide()

  showAllLogs: (e) ->
    e.preventDefault()
    $('.step-logs.expandable').addClass('expanded')
    $('.log.expandable').addClass('expanded')
    $('#show-all-logs').hide()
    $('#hide-all-logs').show()

  hideAllLogs: (e) ->
    e.preventDefault()
    $('.step-logs.expandable').removeClass('expanded')
    $('.log.expandable').removeClass('expanded')
    $('#hide-all-logs').hide()
    $('#show-all-logs').show()
