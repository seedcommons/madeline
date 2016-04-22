class MS.Views.TimelineView extends Backbone.View

  el: 'body'

  initialize: (options) ->
    @loan_id = options.loan_id
    new MS.Views.TimelineSelectStepsView();
    new MS.Views.TimelineBatchActionsView();
    new MS.Views.TimelineHeaderView();

  events:
    'click #new-step': 'addBlankStep'
    'ajax:error': 'submitError'

  # Adds step html, scrolls into view, and focuses first box if visible
  addSteps: (html) ->
    lastStep = @$('.step').last()
    scrollY = if lastStep
      lastStep.offset().top + lastStep.height() - $('.nav').height()
    else
      0
    @$('.project-steps').append(html)
    $('html, body').animate({ scrollTop: scrollY }, 500);
    lastStep.next().find("input[type=text]").focus()

  addBlankStep: (e) ->
    e.preventDefault() if e
    MS.loadingIndicator.show()
    $.get "/admin/project_steps/new?loan_id=#{@loan_id}", (html) =>
      MS.loadingIndicator.hide()
      @addSteps(html)

  submitError: (e) ->
    e.stopPropagation()
    MS.errorModal.modal('show')
    MS.loadingIndicator.hide()
