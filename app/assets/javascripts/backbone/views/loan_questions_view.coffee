class MS.Views.LoanQuestionsView extends Backbone.View

  el: '.loan-questions'

  initialize: (params) ->
    @$('.jqtree').tree({
      data: @$('.jqtree').data('data')
      dragAndDrop: true
      onCreateLi: (node, $li) ->
        $li.data('id', node.id)
            .find('.jqtree-element')
            .addClass('view-block')
            .wrap($('.question-wrapper').html())
            .after($('.links-block').html())
    })

  events: (params) ->
    'click .links .edit-action': 'editNode'

  editNode: (e) ->
    # $(e.target).closest('.view-block').after('
    #   <div class="jqtree-element form-block">
    #     <button class="btn show-action">Cancel</button>
    #   </div>
    # ')
    # $(e.target).closest('.show-view').hide()

    # $(e.target).closest('.show-view').removeClass('show-view').addClass('edit-view')

    qid = $(e.target).closest('li').data('id')
    $('.modal-content').load("/admin/loan_questions/#{qid}/edit")
