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
      @tree.tree 'loadData', @tree.data('data')
      @groupOptional(@tree.tree 'getTree')
      # @groupOptional(@tree.children('ul'))

  # groupOptional: ($root) ->
  #   optional_children = $root.children('li.optional')
  #   if optional_children.length
  #     $root.append $('.optional_questions_group').clone()
  #     $root.find('.optional_questions_group ul').append(optional_children)
  #   for child in $root.children('li')
  #     @groupOptional($(child))

  groupOptional: (root) ->
    if root.children.some( (el) -> el.optional )
      @tree.tree(
        'appendNode',
        { name: I18n.t('questionnaires.optional_questions') },
        root
      )
      newNode = root.children[root.children.length - 1]

      # optional_children = []
      # clones = clone(root.children)
      for id in root.children.map( (i) -> i.id )
        node = @tree.tree('getNodeById', id) if id
        if node && node.optional
          @tree.tree('moveNode', node, newNode, 'inside')
          # optional_children.push node

      # node = optional_children[0]
      # while node
      #   @tree.tree('moveNode', node, newNode, 'inside')
      #   node = optional_children[0]

# clone = (obj) ->
#   if not obj? or typeof obj isnt 'object'
#     return obj
#
#   if obj instanceof Date
#     return new Date(obj.getTime())
#
#   if obj instanceof RegExp
#     flags = ''
#     flags += 'g' if obj.global?
#     flags += 'i' if obj.ignoreCase?
#     flags += 'm' if obj.multiline?
#     flags += 'y' if obj.sticky?
#     return new RegExp(obj.source, flags)
#
#   newInstance = new obj.constructor()
#
#   for key of obj
#     newInstance[key] = clone obj[key]
#
#   return newInstance
