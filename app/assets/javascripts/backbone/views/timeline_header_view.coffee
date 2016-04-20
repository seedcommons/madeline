class MS.Views.TimelineHeaderView extends Backbone.View

  el: 'body'

  events: (params) ->
    'click .filter .btn': 'filterSteps'
    'click #edit-all': 'editAll'

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
    $(e.currentTarget).hide()

