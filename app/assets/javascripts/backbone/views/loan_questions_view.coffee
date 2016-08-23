class MS.Views.LoanQuestionsView extends Backbone.View

  el: '.loan-questions'

  initialize: (params) ->
    new MS.Views.AutoLoadingIndicatorView()
    @tree = @$('.jqtree')
    @tree.tree
      data: @tree.data('data')
      dragAndDrop: true
      selectable: false
      useContextMenu: false
      onCreateLi: (node, $li) ->
        $li.attr('data-id', node.id)
            .addClass("filterable #{node.fieldset}")
            .find('.jqtree-element')
            .append($('.links-block').html())
    @filterSwitchView = new MS.Views.FilterSwitchView()
    @addNewItemBlocks()

  events: (params) ->
    'click .new-action': 'newNode'
    'click .edit-action': 'editNode'
    'submit #edit-modal form.new-form': 'createNode'
    'submit #edit-modal form.update-form': 'updateNode'
    'tree.move .jqtree': 'moveNode'
    'click .delete-action': 'confirmDelete'
    'confirm:complete .delete-action': 'deleteNode'
    'change input[name="custom_field[override_associations]"]': 'showHideAssociations'
    'change .loan-types-container .require-checkbox': 'showHideLoanAmount'
    'change .require-checkbox': 'changeRequireCheckbox'
    'click .amount': 'editAmount'
    'focusout .amount': 'showAmount'
    'change .input-amount': 'adjustAmount'

  newNode: (e) ->
    parent_id = @$(e.target).closest('li').parents('li').data('id')
    fieldset = URI(window.location.href).query(true)['fieldset'] || 'criteria'
    @$('#edit-modal .modal-content').load("/admin/loan_questions/new?fieldset=#{fieldset}", =>
      @$('#edit-modal').modal('show')
      new MS.Views.TranslationsView(el: $('[data-content-translatable="custom_field"]'))
      @$('#custom_field_parent_id').val(parent_id)
      @$('.loan-types').select2()
    )

  editNode: (e) ->
    id = @$(e.target).closest('li').data('id')
    @$('#edit-modal .modal-content').load("/admin/loan_questions/#{id}/edit", =>
      @$('#edit-modal').modal('show')
      new MS.Views.TranslationsView(el: $('[data-content-translatable="custom_field"]'))
      @$('.loan-types').select2()
    )

  createNode: (e) ->
    $form = @$(e.target).closest('form')

    # We send form data via ajax so we can capture the response from server
    $.post($form.attr('action'), $form.serialize())
    .done (response) =>
      # Insert node with data returned from server
      parent_node = @tree.tree('getNodeById', response.parent_id)
      @$('#edit-modal').modal('hide')
      @tree.tree('appendNode', response, parent_node)
      @filterSwitchView.filterInit()
      @addNewItemBlocks()
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
      # Update node on page with data returned from server
      @tree.tree('updateNode', node, response)
      @$('#edit-modal').modal('hide')
      @filterSwitchView.filterInit()
      @addNewItemBlocks()
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

    $.post("/admin/loan_questions/#{id}/move", data)
    .done =>
      e.move_info.do_move()
      @filterSwitchView.filterInit()
      @addNewItemBlocks()
    .fail (response) ->
      MS.alert(response.responseText)

  confirmDelete: (e) ->
    # Replace generic confirmation message with one with specific number of descendants
    id = @$(e.target).closest('li').data('id')
    node = @tree.tree('getNodeById', id)
    @$(e.target).closest('a').attr('data-confirm',
      I18n.t("loan_questions.confirm_deletion_descendants", count: node.descendants_count))

  deleteNode: (e) ->
    id = @$(e.target).closest('li').data('id')
    node = @tree.tree('getNodeById', id)

    $.ajax(type: "DELETE", url: "/admin/loan_questions/#{id}")
    .done =>
      @tree.tree('removeNode', node)
      @filterSwitchView.filterInit()
      @addNewItemBlocks()
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
      @$('.loan-types-container').removeClass('hidden')
    else
      @$('.loan-types-container').addClass('hidden')

  showHideLoanAmount: (e) ->
    checkbox = e.currentTarget
    textbox = @$(checkbox).closest('.form-group').find('.amount')

    if @$(checkbox).is(':checked')
      @$(textbox).removeClass('hidden-special')
    else
      @$(textbox).addClass('hidden-special')

  changeRequireCheckbox: (e) ->
    destroyField = $(e.target).closest('.loan-type').find('.destroy-field')[0]
    destroyField.value = !e.target.checked

  # When the amount field moves out of focus, display a styled version of the user's input
  adjustAmount: (e) ->
    e.preventDefault()
    $inputAmount = @$(e.currentTarget)
    $amountContainer = $inputAmount.closest('.amount')
    $displayAmount = $amountContainer.find('.display-amount')

    value = parseFloat($inputAmount.val())
    value = value.toLocaleString('en', { minimumFractionDigits: 2, maximumFractionDigits: 2})
    $displayAmount.html(value)

  showAmount: (e) ->
    item = e.currentTarget
    $displayAmount = @$(item).find('.display-amount')
    $inputAmount = @$(item).find('.input-amount')

    if $inputAmount.val()
      $displayAmount.removeClass('hidden')
      $inputAmount.addClass('hidden')

  # When the amount field has focus, hide styled amount and show input
  editAmount: (e) ->
    e.preventDefault()
    item = e.currentTarget
    $displayAmount = @$(item).find('.display-amount')
    $inputAmount = @$(item).find('.input-amount')

    if $displayAmount
      $displayAmount.addClass('hidden')
      $inputAmount.removeClass('hidden')
      $inputAmount.focus()
