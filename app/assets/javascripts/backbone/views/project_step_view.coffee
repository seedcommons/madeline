class MS.Views.ProjectStepView extends Backbone.View

  TYPE_ICONS:
    'step': 'flag'
    'milestone': 'calendar-check-o'

  initialize: ->
    @initTypeSelect()

  events:
    'click a.edit-step-action': 'showForm'
    'click a.cancel': 'hideForm'

  showForm: (e) ->
    e.preventDefault()
    @$('.view-step-block').hide()
    @$('.form-step-block').show()

  hideForm: (e) ->
    e.preventDefault()
    @$('.view-step-block').show()
    @$('.form-step-block').hide()

  # Select 2 is used to show the pretty icons.
  initTypeSelect: ->
    @$('.type').select2({
      theme: "bootstrap",
      minimumResultsForSearch: Infinity,
      width: "100%",
      templateResult: (option) => @formatTypeOptions(option),
      templateSelection: (option) => @formatTypeOptions(option)
    });

  formatTypeOptions: (option) ->
    if icon = @TYPE_ICONS[option.id]
      $("<i class=\"fa fa-#{icon}\"></i> <span>#{option.text}</span>")
    else
      $("<span>#{option.text}</span>")
