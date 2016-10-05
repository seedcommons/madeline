# Controls the timeline modal (no more than one per page).
class MS.Views.TimelineTableView extends Backbone.View

  el: 'body'

  initialize: (options) ->
    @loanId = options.loanId

  events:
    'click .timeline-action.edit': 'showTimelineModal'
    'click .timeline-action.new': 'showTimelineModal'
    'click .timeline-action.cancel': 'hideTimelineModal'
    'click .timeline-modal .btn-primary': 'submitForm'
    'ajax:complete .timeline-modal form': 'submitComplete'

  refreshSteps: (callback) ->
    MS.loadingIndicator.show()
    @$('.timeline-table').empty()
    $.get "/admin/loans/#{@loanId}/timeline", (html) =>
      MS.loadingIndicator.hide()
      @$('.timeline-table').html(html)
      callback()

  hideTimelineModal: (e) ->
    e.preventDefault()
    @$('.timeline-modal').modal('hide')

  showTimelineModal: (e) ->
    MS.loadingIndicator.show()
    e.preventDefault()
    link = e.currentTarget

    $.get @$(link).attr('href'), (html) =>
      @$('.timeline-modal .modal-content').html(html)
      @$('.timeline-modal').modal('show')
      new MS.Views.TranslationsView(el: @$('[data-content-translatable="project_group"]'));
      MS.loadingIndicator.hide()

  submitComplete: (e, data) ->
    MS.loadingIndicator.hide()
    if parseInt(data.status) == 200 # data.status is sometimes a string, sometimes an int!?
      @$('.timeline-modal').modal('hide')
      @$('.timeline-table').html(data.responseText)
    else
      @$('.timeline-modal .modal-content').html(data.responseText)

  submitForm: ->
    MS.loadingIndicator.show()
    @$('.timeline-modal form').submit()
