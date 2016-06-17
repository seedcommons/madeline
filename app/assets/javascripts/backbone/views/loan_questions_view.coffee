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
    @tree.find('li:last-child').after($('.new-item-block').html())

  events: (params) ->
    'click .links .edit-action': 'editNode'
    'submit #edit-modal form': 'updateNode'
    'tree.move .jqtree': 'moveNode'

  editNode: (e) ->
    MS.loadingIndicator.show()
    qid = @$(e.target).closest('li').data('id')
    @$('#edit-modal .modal-content').load("/admin/loan_questions/#{qid}/edit", ->
      $('#edit-modal').modal('show')
      new MS.Views.TranslationsView(el: $('[data-content-translatable="loan_question"]'))
      MS.loadingIndicator.hide()
    )

  updateNode: (e) ->
    MS.loadingIndicator.show()
    $form = @$(e.target).closest('form')
    id = $form.data('id')
    node = @tree.tree('getNodeById', id)

    # We send form data via ajax so we can capture the response from server
    $.post($form.attr('action'), $form.serialize()).done( (response) ->
      # Update node on page with data returned from server
      $('.jqtree').tree('updateNode', node, response)
      $('#edit-modal').modal('hide')
    ).fail( (response) ->
      $('.modal-content').html(response.responseText)
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

    $.post("/admin/loan_questions/#{id}/move", data).done( ->
      e.move_info.do_move()
      MS.loadingIndicator.hide()
    ).fail( (response) ->
      MS.loadingIndicator.hide()
      $alert = $(response.responseText).hide()
      $alert.appendTo($('.alerts')).show('fast')
    )
