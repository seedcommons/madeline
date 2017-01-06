class MS.Views.EditableTableView extends Backbone.View

  # The view is called from the loan questionnaires view.

  events:
    'click tr [data-action="delete"]': 'removeRow'
    'click .actions [data-action="add"]': 'addRow'

  initialize: (e) ->
    @$el.find('tbody').sortable(
      handle: "[data-action='move']"
    )

  addRow: (e) ->
    e.preventDefault()
    $button = @$(e.currentTarget)
    $table = $button.closest('table')
    $newRow = $table.find('tr.hidden').clone()
    $newRow.removeClass('hidden')
    $table.append($newRow)

  removeRow: (e) ->
    e.preventDefault()
    @$(e.currentTarget).closest('tr').remove()
