# Handles clicks on the tabs on the loan page.
# Initializes Views for each of the tabs where necessary, but only once they are clicked on.
class MS.Views.LoanTabView extends Backbone.View

  initialize: (params) ->
    @loanId = params.loanId
    @calendarEventsUrl = params.calendarEventsUrl
    @locale = params.locale

    # This is shared among several tabs so we initialize it here.
    @stepModal = new MS.Views.ProjectStepModalView()

    new MS.Views.TabHistoryManager(el: @el, basePath: "/admin/loans/#{@loanId}")

  events:
    'shown.ms.tab': 'tabShown'

  tabShown: (e) ->
    tabName = @$(e.target).data('tab-id')
    switch tabName
      when 'details'
        if MS.detailsView
          MS.detailsView.refresh()
        else
          MS.detailsView = new MS.Views.DetailsView(loanId: @loanId)

      when 'questions'
        if MS.loanQuestionnairesView
          MS.loanQuestionnairesView.refreshContent()
        else
          MS.loanQuestionnairesView = new MS.Views.LoanQuestionnairesView(loanId: @loanId)

      when 'timeline-list'
        if MS.timelineView
          MS.timelineView.refreshSteps()
        else
          MS.timelineView = new MS.Views.TimelineView(loanId: @loanId)

      when 'timeline-table'
        if MS.timelineTableView
          MS.timelineTableView.refresh()
        else
          MS.timelineTableView = new MS.Views.TimelineTableView(loanId: @loanId, stepModal: @stepModal)

      when 'loan-calendar'
        if MS.calendarView
          MS.calendarView.refresh()
        else
          MS.calendarView = new MS.Views.CalendarView(
            calendarEventsUrl: @calendarEventsUrl,
            stepModal: @stepModal,
            locale: @locale
          )
