class MS.Views.QuestionsView extends Backbone.View

  el: '.loan-questions'

  initialize: (params) ->
    new MS.Views.AutoLoadingIndicatorView()
    @locale = params.locale
    @qsetId = params.qsetId
    @popoverView = params.popoverView
    @selectedDivisionDepth = params.selectedDivisionDepth
    @tree = @$('.jqtree')
    @tree.tree
      data: params.questions
      dragAndDrop: true
      selectable: false
      onCanMove: @canMove.bind(this)
      onCanMoveTo: @canMoveTo.bind(this)
      useContextMenu: false
      saveState: "qset#{@qsetId}"
      onCreateLi: @buildListItem.bind(this)
    @addNewItemBlocks()

    # The prepTooltips is called globally on page init, but the jqTree is not in the DOM yet so
    # it does not affect us.
    @popoverView.prepTooltips()

  events: (params) ->
    'click .new-action': 'newNode'
    'click .edit-action': 'editNode'
    'submit #edit-modal form.new-form': 'createNode'
    'submit #edit-modal form.update-form': 'updateNode'
    'tree.move .jqtree': 'moveNode'
    'click .delete-action': 'confirmDelete'
    'confirm:complete .delete-action': 'deleteNode'
    'change [name="question[override_associations]"]': 'showHideAssociations'
    'change .require-checkbox': 'changeRequireCheckbox'

  canMove: (node) ->
    node.can_edit

  canMoveTo: (movedNode, targetNode, position) ->
    return false if position == 'inside' && targetNode.data_type != 'group'

    newParent = if position == 'inside' then targetNode else targetNode.parent
    ownDivisionDepth = movedNode.division_depth
    return false if newParent.division_depth > ownDivisionDepth

    siblings = newParent.children
    targetIndex = siblings.indexOf(targetNode)
    insertIndex =
      switch position
        when 'inside' then 0
        when 'before' then targetIndex
        else targetIndex + 1

    # Ensure left sibling is in same or ancestor division, right sibling in same or descendant division
    (insertIndex == 0 || siblings[insertIndex - 1].division_depth <= ownDivisionDepth) &&
      (insertIndex >= siblings.length || siblings[insertIndex].division_depth >= ownDivisionDepth)

  newNode: (e) ->
    e.preventDefault()
    parent_id = @$(e.target).closest('li').parents('li').data('id') || ''
    @$('#edit-modal .modal-content').load "/admin/questions/new?qset=#{@qsetId}&parent_id=#{parent_id}", =>
      @showModal()

  editNode: (e) ->
    e.preventDefault()
    id = @$(e.target).closest('li').data('id')
    @$('#edit-modal .modal-content').load "/admin/questions/#{id}/edit", =>
      @showModal()

  showModal: ->
    @$('#edit-modal').modal('show')
    new MS.Views.TranslationsView(el: $('[data-content-translatable="question"]'))
    # Use current value of override parent to determine if loan types are shown
    @$('[name="question[override_associations]"]').trigger('change')

  createNode: (e) ->
    $form = @$(e.target).closest('form')

    # We send form data via ajax so we can capture the response from server
    $.post($form.attr('action'), $form.serialize())
    .done (response) =>
      @refreshTree(response)
      @$('#edit-modal').modal('hide')
    .fail (response) =>
      @$('.modal-content').html(response.responseText)

    # Prevent form from being submitted again
    return false

  updateNode: (e) ->
    $form = @$(e.target).closest('form')
    id = $form.data('id')
    node = @tree.tree('getNodeById', id)

    # We send form data via ajax so we can capture the response from server
    $.post($form.attr('action'), $form.serialize())
    .done (response) =>
      @refreshTree(response)
      @$('#edit-modal').modal('hide')
    .fail (response) =>
      @$('.modal-content').html(response.responseText)

    # Prevent form from being submitted again
    return false

  moveNode: (e) ->
    e.preventDefault()
    id = e.move_info.moved_node.id
    data =
      _method: 'patch'
      target: e.move_info.target_node.id
      relation: e.move_info.position # before, after, or inside

    $.post("/admin/questions/#{id}/move", data)
    .done (response) =>
      @refreshTree(response)
    .fail (response) ->
      MS.alert(response.responseText)

  confirmDelete: (e) ->
    # Replace generic confirmation message with one with specific number of descendants
    id = @$(e.target).closest('li').data('id')
    node = @tree.tree('getNodeById', id)
    @$(e.target).closest('a').attr('data-confirm',
      I18n.t("questions.confirm_deletion_#{if node.children.length then '' else 'no_'}descendants", locale: @locale))

  deleteNode: (e, resp) ->
    id = @$(e.target).closest('li').data('id')
    node = @tree.tree('getNodeById', id)

    if (resp)
      $.ajax(type: "DELETE", url: "/admin/questions/#{id}")
      .done (response) =>
        @refreshTree(response)
      .fail (response) ->
        MS.alert(response.responseText)
      return false

  buildListItem: (node, $li) ->
    $li.attr('data-id', node.id)
      .attr('data-division-depth', node.division_depth)
      .addClass(if node.active then 'active' else 'inactive')
      .find('.jqtree-element')
      .addClass(if node.can_edit then 'editable' else 'read-only')
      .append(@tagHTML(node))
      .append(@permittedActionsHTML(node))

  addNewItemBlocks: ->
    # Remove all New Item blocks then re-add after last child at each level
    @tree.find('.new-item').remove()

    # Add a new item block to the top level.
    @tree.find("> ul > li:last-child").after(@$('.new-item-block').html())

    # Add a new item block to groups at the same or higher division depth as the selected division.
    for depth in [0..@selectedDivisionDepth]
      @tree.find("li[data-division-depth=#{depth}] > ul > li:last-child").after(@$('.new-item-block').html())

    # Ensure at least one
    if @tree.find('.new-item').size() == 0
      @tree.find('ul').append(@$('.new-item-block').html())

  showHideAssociations: (e) ->
    overrideParent = e.currentTarget

    if @$(overrideParent).val() == "true"
      @$('.loan-types-table').show()
    else
      @$('.loan-types-table').hide()

  changeRequireCheckbox: (e) ->
    destroyField = $(e.target).closest('tr').find('.destroy-field')
    destroyField.val(!e.target.checked)

  tagHTML: (node) ->
    "<div class='tags'>#{@inheritanceTagHTML(node)}#{@requiredLoanTypesTagHTML(node)}</div>"

  inheritanceTagHTML: (node) ->
    return "" unless node.inheritance_info
    "<div class='inheritance-tag'>#{node.inheritance_info}</div>"

  requiredLoanTypesTagHTML: (node) ->
    # For each loan type required, add a conatiner with its label
    node.required_loan_types.map (loan_type) ->
      "<div class='loan-type-required'>#{loan_type}</div>"
    .join('')

  permittedActionsHTML: (node) ->
    if node.can_edit
      $('.links-block').html()
    else
      $('.actions-disabled-block').html()

  # Update tree with data returned from server
  # Remember the state of which nodes are expanded (subtrees)
  refreshTree: (response) ->
    @tree.tree('loadData', response)
    @addNewItemBlocks()

    # The refresh process creates new nodes so we need to initialize popovers for them again.
    @popoverView.prepTooltips()
