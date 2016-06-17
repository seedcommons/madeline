class MS.Views.TimelineView extends Backbone.View

  el: 'section.timeline'

  initialize: (options) ->
    @loanId = options.loanId

    new MS.Views.TimelineSelectStepsView();
    new MS.Views.TimelineBatchActionsView();
    new MS.Views.TimelineHeaderView();

    @refreshSteps()

  events:
    'click #new-step': 'addBlankStep'
    'ajax:error': 'submitError'

  refreshSteps: ->
    MS.loadingIndicator.show()
    @$('.project-steps').empty()
    $.get "/admin/loans/#{@loanId}/steps", (html) =>
      MS.loadingIndicator.hide()
      @$('.project-steps').html(html)
      @addBlankStep() if @stepCount() == 0

  # Adds step html, scrolls into view, and focuses first box if visible
  addSteps: (html) ->
    lastStep = @$('.step').last()
    scrollY = if lastStep.length > 0
      lastStep.offset().top + lastStep.height() - $('.nav').height()
    else
      0
    @$('.project-steps').append(html)
    $('html, body').animate({ scrollTop: scrollY }, 500);
    lastStep.next().find("input[type=text]").focus()
    @showHideNoStepsMsg()

  removeStep: (el) ->
    el.remove()
    @showHideNoStepsMsg()

  addBlankStep: (e) ->
    e.preventDefault() if e
    MS.loadingIndicator.show()
    $.get "/admin/project_steps/new?loan_id=#{@loanId}", (html) =>
      MS.loadingIndicator.hide()
      @addSteps(html)

  submitError: (e) ->
    e.stopPropagation()
    MS.errorModal.modal('show')
    MS.loadingIndicator.hide()

  showHideNoStepsMsg: ->
    @$('#no-steps-msg')[if @stepCount() > 0 then 'hide' else 'show']()

  stepCount: ->
    @$('.step').length
