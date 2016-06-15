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
    # $(e.target).closest('.view-block').after('
    #   <div class="jqtree-element form-block">
    #     <button class="btn show-action">Cancel</button>
    #   </div>
    # ')
    # $(e.target).closest('.show-view').hide()

    # $(e.target).closest('.show-view').removeClass('show-view').addClass('edit-view')

    qid = @$(e.target).closest('li').data('id')
    @$('.modal-content').load("/admin/loan_questions/#{qid}/edit")

  updateNode: (e) ->
    MS.loadingIndicator.show()

    # We send form data via ajax so we can capture the response from server
    $form = @$(e.target).closest('form')
    $.post($form.attr('action'), $form.serialize(), ((response) ->
      # Update node on page with data returned from server
      id = $form.data('id')
      node = $('.jqtree').tree('getNodeById', id)
      $('.jqtree').tree('updateNode', node, response)
    ), 'json')

    # check for errors here

    @$('#edit-modal').modal('hide')
    MS.loadingIndicator.hide()

    # Prevent form from being submitted again
    return false
