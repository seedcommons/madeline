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
      onCreateLi: (node, $li) =>
        $li.attr('data-id', node.id)
            .addClass("filterable #{node.fieldset}")
            # .find('.jqtree-title')
            # .html(@$(".question[data-id=#{node.id}]").html())
            .find('.jqtree-element')
            # .click( => @tree.tree('toggle', node) )
            .append(@$(".question[data-id=#{node.id}] > .explanation").clone())
            .append(@$(".question[data-id=#{node.id}] > .answer-wrapper").html())
