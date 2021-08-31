class MS.Views.QuestionsView extends Backbone.View

  el: '.loan-questions'

  initialize: (params) ->
    new MS.Views.AutoLoadingIndicatorView()
    @tree = @$('.jqtree')
    @tree.tree
      data: params.questions
      dragAndDrop: true
      selectable: false
      onCanMove: (node) => node.can_edit
      useContextMenu: false
      saveState: true
      onCreateLi: (node, $li) =>
        status = if node.active then 'active' else 'inactive'
        $li.attr('data-id', node.id)
          .addClass("filterable #{node.fieldset} #{status}")
          .find('.jqtree-element')
          .append(@requiredLoanTypesHTML(node))
          .append(@permittedActionsHTML(node))
    @filterSwitchView = new MS.Views.FilterSwitchView()
    @locale = params.locale
    @addNewItemBlocks()

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

  newNode: (e) ->
    e.preventDefault()
    parent_id = @$(e.target).closest('li').parents('li').data('id') || ''
    set = URI(window.location.href).query(true)['filter'] || 'criteria'
    @$('#edit-modal .modal-content').load "/admin/questions/new?set=#{set}&parent_id=#{parent_id}", =>
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

  addNewItemBlocks: ->
    # Remove all New Item blocks then re-add after last child at each level
    @tree.find('.new-item').remove()
    @tree.find('li:last-child').after(@$('.new-item-block').html())
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

  requiredLoanTypesHTML: (node) ->
    # For each loan type required, add a conatiner with its label
    "<div class='loan-types'>" +
      node.required_loan_types.map (loan_type) ->
        "<div class='loan-type-required'>#{loan_type}</div>"
      .join(' ') +
      "</div>"

  permittedActionsHTML: (node) ->
    if node.can_edit
      $('.links-block').html()
    else
      $('.actions-disabled-block').html()

  # Update tree with data returned from server
  # Remember the state of which nodes are expanded (subtrees)
  refreshTree: (response) ->
    @tree.tree('loadData', response)
    @filterSwitchView.filterInit()
    @addNewItemBlocks()
