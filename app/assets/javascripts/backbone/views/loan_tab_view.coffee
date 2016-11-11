# Handles clicks on the tabs on the loan page.
# Initializes Views for each of the tabs where necessary, but only once they are clicked on.
class MS.Views.LoanTabView extends Backbone.View

  initialize: (params) ->
    # Backbone.history.start({pushState: true})
    @listenTo(Backbone, 'popstate', @popstate)
    @loanId = params.loanId
    @calendarEventsUrl = params.calendarEventsUrl

    # This is shared among several tabs so we initialize it here.
    @stepModal = new MS.Views.ProjectStepModalView()

    @openDetails() if @$('.edit-tab').closest('li').hasClass('active')
    @openCalendar() if @$('.calendar-tab').closest('li').hasClass('active')
    @loadSteps() if @$('.timeline-tab').closest('li').hasClass('active')
    @loadTimelineTable() if @$('.timeline-table-tab').closest('li').hasClass('active')
    @loadQuestionnaires() if @$('.questions-tab').closest('li').hasClass('active')

  events: ->
    'shown.bs.tab .edit-tab': 'openDetails'
    'shown.bs.tab .calendar-tab': 'openCalendar'
    'shown.bs.tab .timeline-tab': 'loadSteps'
    'shown.bs.tab .timeline-table-tab': 'loadTimelineTable'
    'shown.bs.tab .questions-tab': 'loadQuestionnaires'
    'shown.bs.tab a[data-toggle="tab"]': 'updateState'
    # 'click a[data-toggle="tab"]': 'clickLink'

  clickLink: (e) ->
    e.preventDefault()
    e.stopPropagation()

  popstate: (e) ->
    console.log(window.location.href)
    uri = URI(window.location.href).filename()
    console.log(uri)
    @changeActiveTab(uri)

  updateState: (e) ->
    $tab = @$(e.target)
    href = $tab.attr("href")

    # This check if the tab is active
    if $tab.parent().hasClass('active')
      console.log('the tab with the content id ' + href + ' is visible')
    else
      console.log('the tab with the content id ' + href + ' is NOT visible')

    # We use replaceState because by default, bootstrap adds an anchor to the URL, and we want to replace that
    history.replaceState(null, "", "/admin/loans/#{@loanId}/#{href}")
    @changeActiveTab(href)

  changeActiveTab: (tabName) ->
    $('.tab-pane').toggleClass('active', false)
    $("##{tabName}").toggleClass('active', true)

  openDetails: ->
    if MS.detailsView
      MS.detailsView.refresh()
    else
      MS.detailsView = new MS.Views.DetailsView(loanId: @loanId)

  openCalendar: ->
    if MS.calendarView
      MS.calendarView.refresh()
    else
      MS.calendarView = new MS.Views.CalendarView(
        calendarEventsUrl: @calendarEventsUrl,
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
