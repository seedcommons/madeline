class MS.Views.LoanPrintView extends Backbone.View
  events:
    'click [data-print]': 'preparePrint'

  preparePrint: (e) ->
    # TODO: Determine if the Show Edit View should be called here instead
    @$el.addClass('show-view').removeClass('edit-view')
    
    e.preventDefault()
    initiatingItem = e.currentTarget
    printType = @$(initiatingItem).data('print')
    console.log(printType)
