# Handles tabs interaction with browser history
class MS.Views.TabHistoryManager extends Backbone.View

  initialize: (params) ->
    @listenTo(Backbone, 'popstate', @popstate)
    @basePath = params.basePath
    @firstTab = @$('a[role=tab]').first().data('tab-id')
    activeTab = @$('li.tab.active a[role=tab]').data('tab-id')
    @showTab(activeTab)

  events:
    'click a[role=tab]': 'tabClicked'
    'shown.bs.tab a[role=tab]': 'tabShown'

  popstate: (e) ->
    @$("a[role=tab]").blur()
    @showTab(@tabNameFromUrl())

  tabClicked: (e) ->
    tabName = @$(e.target).data('tab-id')
    e.stopPropagation()
    e.preventDefault()
    @showTab(tabName)

  showTab: (tabName) ->
    @$('[role=tabpanel]').hide()
    @$("##{tabName}[role=tabpanel]").show()
    @$("[data-tab-id=#{tabName}]").tab('show')

  tabShown: (e) ->
    tabName = @$(e.target).data('tab-id')
    tabNameWithSlash = if tabName == @firstTab then '' else "/#{tabName}"
    tabPath = "#{@basePath}#{tabNameWithSlash}"
    if (URI(window.location.href).path() != tabPath)
      history.pushState(null, "", tabPath)

  tabNameFromUrl: ->
    URI(window.location.href).path().match(///#{@basePath}\/?(.*)///)[1] || @firstTab
