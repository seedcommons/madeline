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
        $li.data('id', node.id)
            .find('.jqtree-element')
            .after($('.links-block').html())
    @addNewItemBlocks()

  events: (params) ->
    'click .new-action': 'newNode'
    'click .edit-action': 'editNode'
    'click .delete-action': 'deleteNode'
    'submit #edit-modal form.new-form': 'createNode'
    'submit #edit-modal form.update-form': 'updateNode'
    'tree.move .jqtree': 'moveNode'

  newNode: (e) ->
    MS.loadingIndicator.show()
    parent_id = @$(e.target).closest('li').parents('li').data('id')
    @$('#edit-modal .modal-content').load("/admin/loan_questions/new", =>
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
    $.post($form.attr('action'), $form.serialize()).done( (response) =>
      # Insert node with data returned from server
      parent_node = @tree.tree('getNodeById', response.parent_id)
      @$('#edit-modal').modal('hide')
      @tree.tree('appendNode', response, parent_node)
      @addNewItemBlocks()
    ).fail( (response) =>
      @$('.modal-content').html(response.responseText)
    )

    MS.loadingIndicator.hide()
    # Prevent form from being submitted again
    return false

  deleteNode: (e) ->
    # MS.loadingIndicator.show()
    # e.preventDefault()
    id = @$(e.target).closest('li').data('id')
    @$(e.target).attr('href', "/admin/loan_questions/#{id}")

    # $.post("/admin/loan_questions/#{id}", { _method: 'delete' }).done( ->
    #   MS.loadingIndicator.hide()
    # )

  updateNode: (e) ->
    MS.loadingIndicator.show()
    $form = @$(e.target).closest('form')
    id = $form.data('id')
    node = @tree.tree('getNodeById', id)

    # We send form data via ajax so we can capture the response from server
    $.post($form.attr('action'), $form.serialize()).done( (response) =>
      # Update node on page with data returned from server
      @$('.jqtree').tree('updateNode', node, response)
      @$('#edit-modal').modal('hide')
      @addNewItemBlocks()
    ).fail( (response) =>
      @$('.modal-content').html(response.responseText)
    )

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

    $.post("/admin/loan_questions/#{id}/move", data).done( =>
      e.move_info.do_move()
      MS.loadingIndicator.hide()
      @addNewItemBlocks()
    ).fail( (response) ->
      MS.loadingIndicator.hide()
      $alert = $(response.responseText).hide()
      $alert.appendTo($('.alerts')).show('fast')
    )

  addNewItemBlocks: ->
    # Remove all New Item blocks then re-add after last child at each level
    @tree.find('.new-item-block').remove()
    @tree.find('li:last-child').after(@$('.new-item-block').html())
