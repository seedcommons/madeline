class MS.Views.TimelineView extends Backbone.View

  el: 'body'

  initialize: ->
    new MS.Views.TimelineSelectStepsView();
    new MS.Views.TimelineBatchActionsView();

  addStepsAndScroll: (html) ->
    lastStep = @$('.step').last()
    scrollY = if lastStep
      lastStep.offset().top + lastStep.height() - $('.nav').height()
    else
      0
    @$('.project-steps').append(html)
    $('html, body').animate({ scrollTop: scrollY }, 500);
