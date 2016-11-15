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

  popstate: (e) ->
    @$("a[role=tab]").blur() # Otherwise the old tab stays active with gray BG
    @showTab(@tabNameFromUrl())

  tabClicked: (e) ->
    tabName = @$(e.target).data('tab-id')
    e.stopPropagation()
    e.preventDefault()
    @showTab(tabName)

  showTab: (tabName) ->
    @showPanel(tabName)
    @updateUrl(tabName)
    @$("[data-tab-id=#{tabName}]").tab('show').trigger('shown.ms.tab')

  updateUrl: (tabName) ->
    tabNameWithSlash = if tabName == @firstTab then '' else "/#{tabName}"
    tabPath = "#{@basePath}#{tabNameWithSlash}"
    if (URI(window.location.href).path() != tabPath)
      history.pushState(null, "", tabPath)

  showPanel: (tabName) ->
    @$('[role=tabpanel]').hide()
    @$("##{tabName}[role=tabpanel]").show()

  tabNameFromUrl: ->
    URI(window.location.href).path().match(///#{@basePath}\/?(.*)///)[1] || @firstTab
