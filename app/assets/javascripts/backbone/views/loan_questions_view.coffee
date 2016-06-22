class MS.Views.LoanQuestionsView extends Backbone.View

  el: '.loan-questions'

  initialize: (params) ->
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
            .after($('.links-block').html())
    new MS.Views.FilterSwitchView()
    @addNewItemBlocks()

  events: (params) ->
    'click .new-action': 'newNode'
    'click .edit-action': 'editNode'
    'submit #edit-modal form.new-form': 'createNode'
    'submit #edit-modal form.update-form': 'updateNode'
    'tree.move .jqtree': 'moveNode'
    'click .delete-action': 'confirmDelete'
    'confirm:complete .delete-action': 'deleteNode'

  newNode: (e) ->
    MS.loadingIndicator.show()
    parent_id = @$(e.target).closest('li').parents('li').data('id')
    fieldset = URI(window.location.href).query(true)['fieldset'] || 'criteria'
    @$('#edit-modal .modal-content').load("/admin/loan_questions/new?fieldset=#{fieldset}", =>
      MS.loadingIndicator.hide()
      @$('#edit-modal').modal('show')
      new MS.Views.TranslationsView(el: $('[data-content-translatable="loan_question"]'))
      @$('#custom_field_parent_id').val(parent_id)
    )

  editNode: (e) ->
    MS.loadingIndicator.show()
    id = @$(e.target).closest('li').data('id')
    @$('#edit-modal .modal-content').load("/admin/loan_questions/#{id}/edit", =>
      MS.loadingIndicator.hide()
      @$('#edit-modal').modal('show')
      new MS.Views.TranslationsView(el: $('[data-content-translatable="loan_question"]'))
    )

  createNode: (e) ->
    MS.loadingIndicator.show()
    $form = @$(e.target).closest('form')

    # We send form data via ajax so we can capture the response from server
    $.post($form.attr('action'), $form.serialize())
    .done (response) =>
      # Insert node with data returned from server
      parent_node = @tree.tree('getNodeById', response.parent_id)
      @$('#edit-modal').modal('hide')
      @tree.tree('appendNode', response, parent_node)
      @filterInit()
      @addNewItemBlocks()
    .fail (response) =>
      @$('.modal-content').html(response.responseText)

    MS.loadingIndicator.hide()
    # Prevent form from being submitted again
    return false

  updateNode: (e) ->
    MS.loadingIndicator.show()
    $form = @$(e.target).closest('form')
    id = $form.data('id')
    node = @tree.tree('getNodeById', id)

    # We send form data via ajax so we can capture the response from server
    $.post($form.attr('action'), $form.serialize())
    .done (response) =>
      # Update node on page with data returned from server
      @tree.tree('updateNode', node, response)
      @$('#edit-modal').modal('hide')
      @filterInit()
      @addNewItemBlocks()
    .fail (response) =>
      @$('.modal-content').html(response.responseText)

    MS.loadingIndicator.hide()
    # Prevent form from being submitted again
    return false

  moveNode: (e) ->
    MS.loadingIndicator.show()
    e.preventDefault()
    id = e.move_info.moved_node.id
    data =
      _method: 'patch'
      target: e.move_info.target_node.id
      relation: e.move_info.position # before, after, or inside

    $.post("/admin/loan_questions/#{id}/move", data)
    .done =>
      e.move_info.do_move()
      MS.loadingIndicator.hide()
      @filterInit()
      @addNewItemBlocks()
    .fail (response) ->
      MS.loadingIndicator.hide()
      $alert = $(response.responseText).hide()
      $alert.appendTo($('.alerts')).show('fast')

  confirmDelete: (e) ->
    # Replace generic confirmation message with one with specific number of descendants
    id = @$(e.target).closest('li').data('id')
    node = @tree.tree('getNodeById', id)
    @$(e.target).closest('a').attr('data-confirm',
      I18n.t("loan_questions.confirm_deletion_descendants", count: node.descendants_count))

  deleteNode: (e) ->
    MS.loadingIndicator.show()
    id = @$(e.target).closest('li').data('id')
    node = @tree.tree('getNodeById', id)

    $.ajax(type: "DELETE", url: "/admin/loan_questions/#{id}")
    .done =>
      MS.loadingIndicator.hide()
      @tree.tree('removeNode', node)
      @filterInit()
      @addNewItemBlocks()
    .fail (response) ->
      MS.loadingIndicator.hide()
      $alert = $(response.responseText).hide()
      $alert.appendTo($('.alerts')).show('fast')
    return false

  addNewItemBlocks: ->
    # Remove all New Item blocks then re-add after last child at each level
    @tree.find('.new-item').remove()
    @tree.find('li:last-child').after(@$('.new-item-block').html())
    # Ensure at least one
    if @tree.find('.new-item').size() == 0
      @tree.find('ul').append(@$('.new-item-block').html())
