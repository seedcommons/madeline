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
    # Initialize the jqtree
    @tree.tree
      dragAndDrop: false
      selectable: false
      useContextMenu: false
      # This is fired for each li element in the jqtree just after it's created.
      # We pull pieces from the hidden questionnaire below and insert them.
      # This runs during the loadData event below.
      onCreateLi: (node, $li) =>
        $question = @$(".question[data-id=#{node.id}]")
        $li.attr('data-id', node.id)
            .addClass($question.attr('class'))

        # Don't replace content of 'optional questions' groups
        unless node.id == undefined
          $li.find('.jqtree-title')
              .html($question.children().not('ol').clone())

    # Load the data into each tree from its 'data-data' attribute.
    @tree.each =>
      data = @groupOptional(@tree.data 'data')
      @tree.tree 'loadData', data

  groupOptional: (nodes) ->
    optionalGroupName = I18n.t('questionnaires.optional_questions')

    # Recurse, depth first
    for node in nodes
      if node.children?.length
        node.children = @groupOptional(node.children)

    if nodes.some( (el) -> el.optional )
      # Add optional group to this level
      nodes.push { name: optionalGroupName, children: [] }
      optionalGroup = nodes[nodes.length - 1]

      # child_ids = nodes.map( (i) -> i.id )
      for node in nodes
        # node = @tree.tree('getNodeById', id) if id
        if node.optional
          optionalGroup.children.push node
          # nodes.splice(nodes.indexOf(node), 1)

      # Remove original copies of optional nodes
      nodes = nodes.filter( (node) -> !node.optional )

    nodes
