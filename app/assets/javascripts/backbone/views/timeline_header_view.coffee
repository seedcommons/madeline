class MS.Views.TimelineHeaderView extends Backbone.View

  el: 'body'

  events: (params) ->
    'click .filter-switch .btn': 'filterSteps'
    'click #edit-all': 'editAll'
    'click #edit-all-cancel': 'cancelEdit'
    'click #save-all': 'saveAll'

  initialize: ->
    $('#edit-all-cancel').hide()
    $('#save-all').hide()
    $('.filter-switch .active').click()

  filterSteps: (e) ->
    item = e.currentTarget
    selected = $(item).find('input')[0].value
    if selected == "incomplete"
      $('.step.completed').hide()
      url = URI(window.location.href).setQuery('filter', 'incomplete').href()
      history.pushState(null, "", url)
    else if selected == "all"
      $('.step').show()
      url = URI(window.location.href).setQuery('filter', 'all').href()
      history.pushState(null, "", url)

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

  saveAll: (e) ->
    e.preventDefault()
    $('.project-step-form').submit()

    $('#edit-all').show()
    $('#new-step').show()
    $('#edit-all-cancel').hide()
    $('#save-all').hide()
