class MS.Views.LoanQuestionsView extends Backbone.View

  initialize: (params) ->
    $('.jqtree').tree({
      data: $('.jqtree').data('data')
      dragAndDrop: true
      onCreateLi: (node, $li) ->
        $li.find('.jqtree-element').wrap('
          <div class="flex-container"></div>
        ').after('
          <div class="links">
            <a href="#"><i class="fa fa-pencil"></i></a>
            <a href="#"><i class="fa fa-trash"></i></a>
          </div>
        ')
    })
