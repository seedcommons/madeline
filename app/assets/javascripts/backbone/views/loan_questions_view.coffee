class MS.Views.LoanQuestionsView extends Backbone.View

  el: '.loan-questions'

  initialize: (params) ->
    @tree = @$('.jqtree')
    @tree.tree
      data: @tree.data('data')
      dragAndDrop: true
      onCreateLi: (node, $li) ->
        $li.data('id', node.id)
            .find('.jqtree-element')
            .addClass('view-block')
            .after($('.links-block').html())

  events: (params) ->
    'click .links .edit-action': 'editNode'
    'submit #edit-modal form': 'updateNode'

  editNode: (e) ->
    qid = @$(e.target).closest('li').data('id')
    @$('.modal-content').load("/admin/loan_questions/#{qid}/edit")

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
