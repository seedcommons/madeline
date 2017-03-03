# Handles clicks on the tabs on the loan page.
# Initializes Views for each of the tabs where necessary, but only once they are clicked on.
class MS.Views.LoanTabView extends Backbone.View

  initialize: (params) ->
    @loanId = params.loanId
    @questionnaireFilter = params.questionnaireFilter
    @calendarEventsUrl = params.calendarEventsUrl
    @locale = params.locale

    # This is shared among several tabs so we initialize it here.
    @stepModal = new MS.Views.ProjectStepModalView()

  events:
    'shown.ms.tab': 'tabShown'

  tabShown: (e) ->
    tabName = @$(e.target).data('tab-id')
    switch tabName
      when 'details'
        if @detailsView
          @detailsView.refresh()
        else
          @detailsView = new MS.Views.DetailsView(loanId: @loanId)

      when 'questions'
        if @loanQuestionnairesView
          @loanQuestionnairesView.refreshContent()
        else
          @loanQuestionnairesView = new MS.Views.LoanQuestionnairesView({
            loanId: @loanId,
            questionnaireFilter: @questionnaireFilter
          })

      when 'timeline-list'
        # TODO: Should try to get rid of this global when old timeline is gone.
        if MS.timelineView
          MS.timelineView.refreshSteps()
        else
          MS.timelineView = new MS.Views.TimelineView(projectId: @loanId)

      when 'timeline-table'
        if @timelineTableView
          @timelineTableView.refresh()
        else
          @timelineTableView = new MS.Views.TimelineTableView({
            projectId: @loanId,
            stepModal: @stepModal
          })

      when 'loan-calendar'
        # TODO: Should try to get rid of this global when old timeline is gone.
        if MS.calendarView
          MS.calendarView.refresh()
        else
          MS.calendarView = new MS.Views.GeneralCalendarView(
            calendarEventsUrl: @calendarEventsUrl,
            stepModal: @stepModal,
            locale: @locale
          )

      when 'logs'
        unless @logListView
          @logListView = new MS.Views.LogListView(
            el: '.tab-pane#logs section.log-list',
            refreshUrl: "/admin/logs?loan=#{@loanId}",
            logFormModal: $("<div>").insertAfter(@$el)
          )
        @logListView.refresh()
