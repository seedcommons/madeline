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
    tree = @$('.jqtree')
    processed = []
    # Initialize the jqtree
    tree.tree
      dragAndDrop: false
      selectable: false
      useContextMenu: false
      # This is fired for each li element in the jqtree just after it's created.
      # We pull pieces from the hidden questionnaire below and insert them.
      # This runs during the loadData event below.
      onCreateLi: (node, $li) =>
        unless (node.id == undefined || node.id in processed)
          $question = @$(".question[data-id=#{node.id}]")
          $li.attr('data-id', node.id)
              .addClass($question.attr('class'))
              .find('.jqtree-title')
              .html($question.children().not('ol'))

        processed.push node.id

    # Load the data into each tree from its data-data attribute.
    tree.each (index, tree) =>
      $(tree).tree 'loadData', $(tree).data('data')
      @groupOptional(tree, $(tree).tree 'getTree')

  groupOptional: (tree, root) ->
    if root && root.children.some( (el) -> el.optional )
      $(tree).tree(
        'appendNode',
        { name: I18n.t('questionnaires.optional_questions') },
        root
      )
      # newNode = root.children[root.children.length - 1]
      #
      # for node in root.children
      #   if node.optional
      #     @tree.tree('moveNode', node, newNode, 'inside')
