class MS.Views.LoanQuestionnairesView extends Backbone.View

  el: 'section.questionnaires'

  initialize: (options) ->
    @loanId = options.loanId
    @refreshContent()
    @filterSwitchView = new MS.Views.FilterSwitchView()

  events:
    'ajax:error': 'submitError'

  refreshContent: ->
    MS.loadingIndicator.show()
    @$('.questionnaires-content').load "/admin/loans/#{@loanId}/questionnaires", =>
      MS.loadingIndicator.hide()
      @initializeTree()
      # @tree.tree 'loadData', @loadData()
      @filterSwitchView.filterInit()

  submitError: (e) ->
    e.stopPropagation()
    MS.errorModal.modal('show')
    MS.loadingIndicator.hide()

  initializeTree: ->
    @tree = @$('.jqtree')
    @tree.tree
      data: @tree.data('data')
      dragAndDrop: false
      selectable: false
      useContextMenu: false
      onCreateLi: (node, $li) ->
        $li.attr('data-id', node.id).addClass("filterable #{node.fieldset}")

  # loadData: ->
  #   @dom2json(@$('[data-level="0"]'), 'li')
  #
  # dom2json: ($root, nodeSelector) ->
  #   children = $root.find(nodeSelector)
  #   $root.map =>
  #     id: $root.find(nodeSelector).addBack(nodeSelector).data('id')
  #     name: $root.find('.name').first().text()
  #     children: if children.length then @dom2json(children, nodeSelector) else null
