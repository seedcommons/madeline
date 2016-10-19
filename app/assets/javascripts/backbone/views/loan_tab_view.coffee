# Handles clicks on the tabs on the loan page.
# Initializes Views for each of the tabs where necessary, but only once they are clicked on.
class MS.Views.LoanTabView extends Backbone.View

  initialize: (params) ->
    @calendar_events_url = params.calendar_events_url
    @loanId = params.loanId

    # This is shared among several tabs so we initialize it here.
    @stepModal = new MS.Views.ProjectStepModalView()

    @openCalendar() if @$('.calendar-tab').closest('li').hasClass('active')
    @loadSteps() if @$('.timeline-tab').closest('li').hasClass('active')
    @loadTimelineTable() if @$('.timeline-table-tab').closest('li').hasClass('active')
    @loadQuestionnaires() if @$('.questions-tab').closest('li').hasClass('active')

  events: ->
    'shown.bs.tab .calendar-tab': 'openCalendar'
    'shown.bs.tab .timeline-tab': 'loadSteps'
    'shown.bs.tab .timeline-table-tab': 'loadTimelineTable'
    'shown.bs.tab .questions-tab': 'loadQuestionnaires'

  openCalendar: (e) ->
    if MS.calendarView
      MS.calendarView.refresh()
    else
      MS.calendarView = new MS.Views.CalendarView(
        calendar_events_url: @calendar_events_url,
        stepModal: @stepModal
      )

  loadSteps: ->
    if MS.timelineView
      MS.timelineView.refreshSteps()
    else
      MS.timelineView = new MS.Views.TimelineView(loanId: @loanId)

  loadTimelineTable: ->
    if MS.timelineTableView
      MS.timelineTableView.refresh()
    else
      MS.timelineTableView = new MS.Views.TimelineTableView(loanId: @loanId, stepModal: @stepModal)

  loadQuestionnaires: ->
    if MS.loanQuestionnairesView
      MS.loanQuestionnairesView.refreshContent()
    else
      MS.loanQuestionnairesView = new MS.Views.LoanQuestionnairesView(loanId: @loanId)
